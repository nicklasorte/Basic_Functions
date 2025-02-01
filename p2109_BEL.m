% ITU-R P.2109 Implementation
% Coded up by Mustafa Yilmaz - 10/3/2024
% Building entry loss as defined in ITU P.2109 Section 3, Equation-1
%% Input parameters
% theta is the elevation angle of the path at the building façade [degrees]
% f_GHz is the center frequency [GHz]
% type - 1 for traditional, 2 for thermally efficient
% prob: 0-100
function pl_bel = p2109_BEL(f_GHz,theta,prob,type)
r      = [12.64 28.19];
s      = [3.72 -3];
t      = [0.96 8.48];
u      = [9.6 13.5];
v      = [2 3.8];
w      = [9.1 27.8];
x      = [-3 -2.9];
y      = [4.5 9.4];
z      = [-2 -2.1];
sigma1 = u(type) + v(type)*log10(f_GHz);
sigma2 = y(type) + z(type)*log10(f_GHz);
mu2    = w(type) + x(type)*log10(f_GHz);
L_e    = 0.212*abs(theta); % Correction for elevation angle of the path at the building facade                                          
L_h    = r(type) + s(type)*log10(f_GHz) + t(type)*log10(f_GHz)^2; % Median loss for horizontal paths
mu1    = L_h + L_e;
C      = -3;
A_P    = sigma1*norminv(prob/100) + mu1;
B_P    = sigma2*norminv(prob/100) + mu2;
pl_bel = 10*log10(10^(0.1*A_P)+10^(0.1*B_P)+10^(0.1*C));


%{
% Cod testing: Compare it with Figure-1 in ITU P.2109 document
f_GHz  = 0.1:0.1:100;
theta  = 0;
prob   = 50; 
type   = [1 2];
r      = [12.64 28.19];
s      = [3.72 -3];
t      = [0.96 8.48];
u      = [9.6 13.5];
v      = [2 3.8];
w      = [9.1 27.8];
x      = [-3 -2.9];
y      = [4.5 9.4];
z      = [-2 -2.1];
for k = 1:length(type)
    for i = 1:length(f_GHz)
        sigma1 = u(type(k)) + v(type(k))*log10(f_GHz(i));
        sigma2 = y(type(k)) + z(type(k))*log10(f_GHz(i));
        mu2    = w(type(k)) + x(type(k))*log10(f_GHz(i));
        L_e    = 0.212*abs(theta); % Correction for elevation angle of the path at the building facade
        L_h    = r(type(k)) + s(type(k))*log10(f_GHz(i)) + t(type(k))*log10(f_GHz(i))^2; % Median loss for horizontal paths
        mu1    = L_h + L_e;
        C      = -3;
        A_P    = sigma1*norminv(prob/100) + mu1;
        B_P    = sigma2*norminv(prob/100) + mu2;
        pl_bel(i) = 10*log10(10^(0.1*A_P)+10^(0.1*B_P)+10^(0.1*C));
    end
    semilogx(f_GHz,pl_bel,LineWidth=2)
    hold all
end
grid on,xlabel('Frequency (GHz)'),ylabel('BEL (dB)')
legend('Traditional','Thermally Efficient')
%}