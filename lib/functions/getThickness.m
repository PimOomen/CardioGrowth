function h = getThickness(h0, r0, r)

% Determine wall thickness for (1) remote (2) total and (3) ischemic
% regions, see page 26 CMW notebook 5 

h(:,1) = ( h0(1)^3+3*h0(1)^2*r0(1)+3*h0(1)*r0(1)^2 + r(:,1).^3).^(1/3)-r(:,1); %ischoric
         
h(:,2) = ( h0(2)^3+3*h0(2)^2*r0(2)+3*h0(2)*r0(2)^2 + r(:,2).^3).^(1/3)-r(:,2); %ischoric         

h(:,3) = ( h0(3)^3+3*h0(3)^2*r0(3)+3*h0(3)*r0(3)^2 + r(:,3).^3).^(1/3)-r(:,3); %ischoric, 

