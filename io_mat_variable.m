function out = io_mat_variable(app, mode, file_name, variable_name, varargin)
%IO_MAT_VARIABLE Unified save/load MAT-variable with retries, logging, locking.
%
%   Save:
%     io_mat_variable(app,"save",file_name,variable_name,variable_data)
%     io_mat_variable(...,"PauseTime",1,"MaxRetries",50,"LogFile","io.log")
%
%   Load:
%     data = io_mat_variable(app,"load",file_name,variable_name)

% % SAVE
% io_mat_variable(app,"save","agg_check_mc_size.mat","agg_check_mc_size",agg_check_mc_size,"LogFile","io.log","PauseTime",1,"MaxRetries",100);
% 
% % LOAD
% agg_check_mc_size = io_mat_variable(app,"load","agg_check_mc_size.mat","agg_check_mc_size","LogFile","io.log");
%
%   Name-Value options:
%     "PauseTime"     (default 1)   pause between retries (seconds)
%     "MaxRetries"    (default 50)  number of attempts
%     "LockPauseTime" (default 0.1) pause between lock attempts
%     "LockTimeout"   (default 30)  seconds before giving up acquiring lock
%     "LogFile"       (default "")  append log lines to this file ("" disables)
%     "Verbose"       (default true) show disp_progress(app,...) if available

    % ---------- Parse inputs (Cleve-style, robust) ----------
    if nargin < 4
        error("io_mat_variable requires at least app, mode, file_name, variable_name.");
    end
    mode = string(mode);
    file_name = string(file_name);
    variable_name = string(variable_name);

    % variable_data only for save
    variable_data = [];
    argOffset = 0;
    if mode == "save"
        if numel(varargin) < 1
            error("For mode=""save"", you must provide variable_data as the next argument.");
        end
        variable_data = varargin{1};
        argOffset = 1;
    elseif mode ~= "load"
        error("mode must be ""save"" or ""load"".");
    end

    % Defaults
    opts.PauseTime     = 1;
    opts.MaxRetries    = 50;
    opts.LockPauseTime = 0.1;
    opts.LockTimeout   = 30;
    opts.LogFile       = "";
    opts.Verbose       = true;

    % Name-value parsing
    nv = varargin(1+argOffset:end);
    if rem(numel(nv),2) ~= 0
        error("Name-value inputs must come in pairs.");
    end
    for k = 1:2:numel(nv)
        name = string(nv{k});
        value = nv{k+1};
        switch lower(name)
            case "pausetime"
                opts.PauseTime = value;
            case "maxretries"
                opts.MaxRetries = value;
            case "lockpausetime"
                opts.LockPauseTime = value;
            case "locktimeout"
                opts.LockTimeout = value;
            case "logfile"
                opts.LogFile = string(value);
            case "verbose"
                opts.Verbose = logical(value);
            otherwise
                error("Unknown option: %s", name);
        end
    end

    % ---------- Logging helper (append, single write) ----------
    function logLine(msg)
        if opts.LogFile == ""
            return
        end
        try
            ts = char(datetime("now","Format","yyyy-MM-dd HH:mm:ss.SSS"));
            pid = feature("getpid");
            t = getCurrentTask();
            if isempty(t)
                wid = 0;
            else
                wid = t.ID;
            end
            line = sprintf("[%s] pid=%d worker=%d %s\n", ts, pid, wid, msg);

            % Append as a single operation for better interprocess safety. :contentReference[oaicite:1]{index=1}
            fid = fopen(opts.LogFile, "a");
            if fid >= 0
                c = onCleanup(@() fclose(fid));
                fwrite(fid, line, "char");
            end
        catch
            % Logging must never break I/O.
        end
    end

    % ---------- Progress helper ----------
    function progress(msg)
        if opts.Verbose && ~isempty(app)
            try
                disp_progress(app, msg);
            catch
                % ignore
            end
        end
    end

    % ---------- Locking (atomic mkdir lock folder) ----------
    % Common MATLAB pattern: mkdir succeeds for only one contender. :contentReference[oaicite:2]{index=2}
    lockDir = file_name + ".lock";
    ownerFile = fullfile(lockDir, "owner.txt");

    function acquireLock()
        tStart = tic;
        while true
            [ok,~,~] = mkdir(lockDir);
            if ok
                % mark owner
                try
                    fid = fopen(ownerFile,"w");
                    if fid >= 0
                        c = onCleanup(@() fclose(fid));
                        pid = feature("getpid");
                        task = getCurrentTask();
                        if isempty(task), wid = 0; else, wid = task.ID; end
                        fprintf(fid,"pid=%d worker=%d time=%s\n", pid, wid, char(datetime("now")));
                    end
                catch
                end
                return
            end
            if toc(tStart) > opts.LockTimeout
                error("Timeout acquiring lock: %s", lockDir);
            end
            pause(opts.LockPauseTime);
        end
    end

    function releaseLock()
        % Best-effort cleanup
        try, if isfile(ownerFile), delete(ownerFile); end, catch, end
        try, if isfolder(lockDir), rmdir(lockDir,"s"); end, catch, end
    end

    % ---------- Main retry loop ----------
    for attempt = 1:opts.MaxRetries
        try
            acquireLock();
            lockCleanup = onCleanup(@releaseLock);

            if mode == "load"
                progress("Loading: " + variable_name + " ...");
                logLine("LOAD start file=" + file_name + " var=" + variable_name);

                S = load(file_name, variable_name);
                if ~isfield(S, variable_name)
                    error("Variable '%s' not found in file '%s'.", variable_name, file_name);
                end
                out = S.(variable_name);

                logLine("LOAD ok   file=" + file_name + " var=" + variable_name);

            else % save
                progress("Saving: " + variable_name + " ...");
                logLine("SAVE start file=" + file_name + " var=" + variable_name);

                % Atomic save: write temp MAT, then move into place. :contentReference[oaicite:3]{index=3}
                tmp = file_name + ".tmp_" + char(java.util.UUID.randomUUID) + ".mat";

                save_struct = struct();
                save_struct.(variable_name) = variable_data;
                save(tmp, "-struct", "save_struct");

                % Force overwrite if destination exists.
                movefile(tmp, file_name, "f");  % move/rename in one step :contentReference[oaicite:4]{index=4}

                out = []; % save returns nothing
                logLine("SAVE ok   file=" + file_name + " var=" + variable_name);
            end

            return

        catch ME
            % Ensure lock is released via onCleanup if acquired.
            logLine("I/O fail attempt=" + attempt + " mode=" + mode + ...
                    " file=" + file_name + " var=" + variable_name + ...
                    " msg=" + string(ME.message));

            if attempt == opts.MaxRetries
                rethrow(ME);
            end
            pause(opts.PauseTime);
        end
    end
end