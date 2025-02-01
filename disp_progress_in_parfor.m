function disp_progress_in_parfor(app,label1,parallel_flag)
if parallel_flag==0
    if isa(app,'double')
        label1
        %pause(0.01)
    else
        if isvalid(app.TextArea)
            % Text box exists
            app.TextArea.Value={label1};
            pause(0.01)
        else
            % Text box does not exist
        end
    end
end

end