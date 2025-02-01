function disp_TextArea_PastText(app,label1)
   
    if isa(app,'double')
        label1
        %pause(0.01)
    else
        if isvalid(app.TextArea_PastText)
            % Text box exists
            previous_text=app.TextArea_PastText.Value;
            previous_text=previous_text(~cellfun(@isempty, previous_text));
            full_text=flipud(vertcat(flipud(previous_text),{label1}));
            if length(full_text)>15
                app.TextArea_PastText.Value=full_text(1:15);
                full_text(1:15)
            else
                app.TextArea_PastText.Value=full_text;
                full_text
            end
            pause(0.01)
        else
            % Text box does not exist
        end
    end
end