%%This code is from the professor since I could not complete assignment 2
fprintf('Part 2\n')
q = 1.602e-19;  %Coul
kB = 1.38066e-23; %J/K
m0 = 9.11e-31;  %kg
mn = 0.26*m0;
mp = 0.29*m0;
un = 1400/1e4;  %electron mobility m^2/V-s
up = 470/1e4;   %hole mobility     m^2/V-s

% model parameters
n = 1e18;       %cm^-3
LatticeTemp = 300;   %K

Width = 200e-9;
nx = 200;
Height = 100e-9;
ny  = 100;
%  Boxes =  {};
Boxes{1}.X = [0.8 1.2]*1e-7;
Boxes{1}.Y = [0.6 1.0]*1e-7;
Boxes{1}.BC = 0.0;

Boxes{2}.X = [0.8 1.2]*1e-7;
Boxes{2}.Y = [0.0 0.4]*1e-7;
Boxes{2}.BC = 0.0;
%{
Boxes{3}.X = [1.4 1.6]*1e-7;
Boxes{3}.Y = [0.4 0.6]*1e-7;
Boxes{3}.BC = 's';
%}
Vo = 1; %0.02;
[ Curr, Vmap, Ex, Ey, eFlowx, eFlowy  ] = ...
    Poisson(Width,Height,nx,ny,1,0.00001,[Vo 0],Boxes);
figure('name','Part 2')
%creating the potential plot
subplot(2,1,1),H = surf(Vmap');
set(H, 'linestyle', 'none');
%view(0,90)
title('V(x,y)')
xlabel('x')
ylabel('y')

%creating the electric field plot
global fieldQ3X fieldQ3Y;
[fieldQ3X,fieldQ3Y] = gradient(Vmap);
domain = linspace(0,Width,nx);
range = linspace(0,Height,ny);
subplot(2,1,2),quiver(domain,range,fieldQ3X',fieldQ3Y'); %do I need to transpose? yes
title('2-D electric field')
%axis([0 Height 0 Width]);

maxE = max(max(abs(eFlowx)));

Fx = q*eFlowx;
Fy = q*eFlowy;


function [ Curr, Vmap, Ex, Ey, eFlowx, eFlowy  ] = ...
    Poisson(Xmax,Ymax,nx,ny,Acond,Bcond,BC,Boxes)

cMap = ones(nx,ny)*Acond;

if ~isempty(Boxes)
    for b = 1:length(Boxes)
        x0 = Boxes{b}.X(1);
        x1 = Boxes{b}.X(2);
        y0 = Boxes{b}.Y(1);
        y1 = Boxes{b}.Y(2);
        for i = 1:nx
            x = i/nx*Xmax;
            for j = 1:ny
                y = j/ny*Ymax;
                if (x >= x0 && x <= x1 && y >= y0 && y <= y1)
                    cMap(i,j) = Bcond;
                end
            end
        end
    end
end

% subplot(2,2,1),H = surf(cMap');

G = sparse(nx*ny);
B = zeros(1,nx*ny);

for i = 1:nx
    for j = 1:ny
        n = j + (i-1)*ny;
        
        if i == 1
            G(n,:) = 0;
            G(n,n) = 1;
            B(n) = BC(1);
        elseif i == nx
            G(n,:) = 0;
            G(n,n) = 1;
            B(n) = BC(2);
        elseif j == 1
            if length(BC) > 2
                G(n,:) = 0;
                G(n,n) = 1;
                B(n) = BC(3);
            else
                nxm = j + (i-2)*ny;
                nxp = j + (i)*ny;
                nyp = j+1 + (i-1)*ny;
                
                rxm = (cMap(i,j) + cMap(i-1,j))/1.0;
                rxp = (cMap(i,j) + cMap(i+1,j))/1.0;
                ryp = (cMap(i,j) + cMap(i,j+1))/2.0;
                
                G(n,n) = -(rxm+rxp+ryp);
                G(n,nxm) = rxm;
                G(n,nxp) = rxp;
                G(n,nyp) = ryp;
            end
        elseif j ==  ny
            
            if length(BC) > 2
                G(n,:) = 0;
                G(n,n) = 1;
                B(n) = BC(4);
            else
                nxm = j + (i-2)*ny;
                nxp = j + (i)*ny;
                nym = j-1 + (i-1)*ny;
                
                rxm = (cMap(i,j) + cMap(i-1,j))/1.0;
                rxp = (cMap(i,j) + cMap(i+1,j))/1.0;
                rym = (cMap(i,j) + cMap(i,j-1))/2.0;
                
                G(n,n) = -(rxm+rxp+rym);
                G(n,nxm) = rxm;
                G(n,nxp) = rxp;
                G(n,nym) = rym;
                
                
            end
        else
            nxm = j + (i-2)*ny;
            nxp = j + (i)*ny;
            nym = j-1 + (i-1)*ny;
            nyp = j+1 + (i-1)*ny;
            
            rxm = (cMap(i,j) + cMap(i-1,j))/2.0;
            rxp = (cMap(i,j) + cMap(i+1,j))/2.0;
            rym = (cMap(i,j) + cMap(i,j-1))/2.0;
            ryp = (cMap(i,j) + cMap(i,j+1))/2.0;
            
            G(n,n) = -(rxm+rxp+rym+ryp);
            G(n,nxm) = rxm;
            G(n,nxp) = rxp;
            G(n,nym) = rym;
            G(n,nyp) = ryp;
        end
        
    end
end



V = G\B';

Vmap = zeros(nx,ny);
for i = 1:nx
    for j = 1:ny
        n = j + (i-1)*ny;
        
        Vmap(i,j) = V(n);
    end
end

dx = Xmax/nx;
dy = Ymax/ny;

for i = 1:nx
    for j = 1:ny
        if i == 1
            Ex(i,j) = (Vmap(i+1,j) - Vmap(i,j));
        elseif i == nx
            Ex(i,j) = (Vmap(i,j) - Vmap(i-1,j));
        else
            Ex(i,j) = (Vmap(i+1,j) - Vmap(i-1,j))*0.5;
        end
        if j == 1
            Ey(i,j) = (Vmap(i,j+1) - Vmap(i,j));
        elseif j == ny
            Ey(i,j) = (Vmap(i,j) - Vmap(i,j-1));
        else
            Ey(i,j) = (Vmap(i,j+1) - Vmap(i,j-1))*0.5;
        end
    end
end

Ex = -Ex/dx;
Ey = -Ey/dy;

eFlowx = cMap.*Ex;
eFlowy = cMap.*Ey;

% 
% set(H, 'linestyle', 'none');
% view(0,90)
% subplot(2,2,2),H = surf(Vmap');
% set(H, 'linestyle', 'none');
% view(0,90)
% subplot(2,2,3),quiver(Ex',Ey');
% axis([0 nx 0 ny]);
% subplot(2,2,4),quiver(eFlowx',eFlowy');
% axis([0 nx 0 ny]);


C0 = sum(eFlowx(1,:));
Cnx = sum(eFlowx(nx,:));

Curr = [(C0 + Cnx)*0.5 C0 Cnx];


end
