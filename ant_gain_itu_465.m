function [ant_gain]=ant_gain_itu_465(app)

array_theta=0:1:180;
num_theta=length(array_theta);
ant_gain=NaN(num_theta,2);
for i=1:1:num_theta
    temp_theta=array_theta(i);
    if temp_theta<48
        ant_gain(i,2)=32-25*log10(temp_theta);
    else
        ant_gain(i,2)=-10;
    end
    ant_gain(i,1)=temp_theta;
end

% figure;
% hold on;
% plot(ant_gain(:,1),ant_gain(:,2),'or')
% grid on;

end