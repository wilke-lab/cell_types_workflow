% Written by SAW, 012220
% Function that sorts one matrix by the time of maximum signal, then sorts
% a second matrix in the exact same order. 
function [sortedmat, sortedmat2, sortedmat3, sortedmat4] = sort_max_time(IS, SI)

% Define the transition matrix to look at
 trans_sig = IS;
 other_sig = SI;

 % Sort that matrix by time of maximum value
 [M,I] = max(trans_sig');
 special = (I');
 new = [special trans_sig];
 sortedmat = sortrows(new,1);
 sortedmat(:,1) = [];
 
 % Sort counterexample matrix based on same order as trans_sig
 new2 = [special other_sig];
 sortedmat2 = sortrows(new2,1);
 sortedmat2(:,1) = [];
 
 % Do the reverse now
 [Q,S] = max(other_sig');
 unique = (S');
 new3= [unique other_sig];
 sortedmat3 = sortrows(new3,1);
 sortedmat3(:,1) = [];
 
 new4 = [unique trans_sig];
 sortedmat4 = sortrows(new4,1);
 sortedmat4(:,1) = [];
 
 
 
 
 % Plot sorted figure
 %figure
 %imagesc(sortedmat);
 %colorbar
 %caxis([-1 1]);
 
 % Plot original figure
 %figure
 %imagesc(trans_sig);
 %colorbar
 %caxis([-1 1]);
 
 % Plot counterexample sorted by trans_sig
 %figure
 %imagesc(sortedmat2);
 %colorbar
 %caxis([-1 1]);

