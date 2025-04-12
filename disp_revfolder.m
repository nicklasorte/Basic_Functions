function disp_revfolder(app,label1)

    if isa(app,'double')
        label1
        %pause(0.01)
    else
        if isvalid(app.TextArea_RevFolder)
            % Text box exists
            app.TextArea_RevFolder.Value={label1};
            pause(0.01)

        else
            % Text box does not exist
        end
    end
    
end