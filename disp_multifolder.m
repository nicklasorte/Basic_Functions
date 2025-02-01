function disp_multifolder(app,label1)

    if isa(app,'double')
        label1
        %pause(0.01)
    else
        if isvalid(app.TextArea_Multifolder)
            % Text box exists
            app.TextArea_Multifolder.Value={label1};
            pause(0.01)

        else
            % Text box does not exist
        end
    end
    
end