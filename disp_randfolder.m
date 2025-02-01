function disp_randfolder(app,label1)

    if isa(app,'double')
        label1
        %pause(0.01)
    else
        if isvalid(app.TextArea_RandFolder)
            % Text box exists
            app.TextArea_RandFolder.Value={label1};
            pause(0.01)

        else
            % Text box does not exist
        end
    end
    
end