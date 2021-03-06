% This file is part of LCToolbox.
% (c) Copyright 2018 - MECO Research Team, KU Leuven. 
%
% LCToolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published 
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% LCToolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with LCToolbox. If not, see <http://www.gnu.org/licenses/>.

clear all
close all
clc

%% 1. Connecting an augmented plant 
% Consider the system G for which we want to design a feedback controller
% K using a Hinf methodology. Two weights are being applied, MS (maximum 
% sensitivity) and WT, a robustness weight.
% Now we can start designing a controller using the lti_toolbox

%% 1.1. Let's define the systems we will be using
Gmod = ZPKmod([-2*pi*3*exp(j*pi/2.5),-2*pi*3*exp(-j*pi/2.5)],[0,-2*pi*5*exp(j*pi/2.5),-2*pi*5*exp(-j*pi/2.5)],10);

MS = Weight.DC(5); % weightDC constructs a dc weight equivalent with a peak of 5db
WT = zpk([-10*2*pi,-10*2*pi],[-1e3*2*pi;-1e3*2*pi],2.5e3); % robustness weight 

%% 1.2. Design a (simple) controller using the lti_toolbox
G = IOSystem(1,1);
G.add(Gmod);
K = IOSystem(1,1);  

r = Signal();
u = G.in;
y = G.out;
e = r - y;

% Make connections
% Assign the error to the controller input
% Assign the plant input to the controller output
connections = [K.in == e; K.out == u];
P = IOSystem(G,K,connections);
    
% Do the controller design
S = Channel(e/r,'Sensitivity');
U = Channel(u/r,'Input Sensitivity');
T = Channel(y/r,'Complementary Sensitivity');

objective = [];
constraints = [MS*S <= 1, WT*T <= 1];
[P,C,info] = P.solve(objective, constraints, K);

figure, bodemag(info);

%% 1.3. Discussion
% As you can see, the toolbox automatically takes care of the construction
% of the generalized/augmented plant, selects a suitable solver and
% computes the requested controller. Plots are automatically generated for
% all performance channels and the controller.
% 
% What do you think of the controller? Although it satisfies our requests,
% the bandwidth is quite poor. Maybe we should also impose a constraint on
% the low frequency behavior of the sensitivity, so let's head to example
% 3.