%%Question 2

mo = 9.1e-31; %mass in kg
mn = 0.26*mo; %mass of electrons


regionW = [0 200e-9]; %width of region
regionL = [0 100e-9]; %Length of region

T = 300; %in Kelvin
kB = 1.28e-23; %in J/K
vthrms = sqrt((kB*T)/mn); %thermal velocity rms

tmn = 0.2e-12; %mean time between collisions
tstep = 0.01e-12;
mfp = vthrms * tmn; %mean free path
%n = 1 + zero(1,1000); %number of molecules
%mbd = (2/sqrt(pi)) .* n .* ((1/(k*T)^(3/2));

%creating electrons
x = regionW(1,2).*rand(1,1000); %position
y = regionL(1,2).*rand(1,1000); 
%ceating velocity
vx = randn(1,1000) .* vthrms;
vy = randn(1,1000) .* vthrms;
vf = sqrt(vy.^2 + vx.^2);

figure('name','Part2')

subplot(2,2,3)
hist(vf,100)

%Scattering
pScat = 1 - exp(1)^(-(tstep/tmn)) + zeros(size(vf));

for n = 1:200    
    x = x + vx.*tstep;
    y = y + vy.*tstep;
    
    %when particle hit bottom or top
    vy(y <= 0) = -vy(y<=0);
    vy(y>=100e-9) = -vy(y>=100e-9);
    %when particle hit sides
    x(x<=0) = x(x<=0)+200e-9;
    x(x>=200e-9) = x(x>=200e-9)-200e-9;
   
    prob = rand(size(vf)) ;
    vy(pScat > prob) = randn .* vthrms;
    vx(pScat > prob) = randn .* vthrms;
    vf = sqrt(vy.^2 + vx.^2);
    %creating plot area
    subplot(2,2,1)
    
    %particles to be graphed
    showx = x(1:10);
    showy = y(1:10);
    
    %plot of particles
    colours = linspace(1,10,length(showx));
    scatter(showx,showy,50,colours,'.')
    xlim(regionW)
    ylim(regionL)
    title('Particle movement')
    pause(0.001)
    hold on
    
    
    %plot of tempture
    subplot(2,2,2)
    temp = (mn/kB)*mean(vf)^2;
    scatter(n,temp,400,'r','.')
    title('Temperature (K)')
    hold on
    
    %mtmn = 
    
end

    
