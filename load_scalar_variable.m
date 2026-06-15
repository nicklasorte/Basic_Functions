function variable_data=load_scalar_variable(app,file_name,variable_name)
loaded_data=load(file_name,variable_name);
variable_data=loaded_data.(variable_name);
end