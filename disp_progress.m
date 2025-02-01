function disp_progress(app,label1)

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