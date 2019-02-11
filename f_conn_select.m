function [ coral_connectivity, cots_connectivity ] = f_conn_select( conn_regime, year, ACROCNS, COTSCNS )
%F_CORAL_CONN Summary of this function goes here
%   Detailed explanation goes here

% how to use yearly matrices
switch conn_regime
    case 1%always use the same matrix, first one
        yr=1;
        
    case 2%use the yearly matrix in regular succession
%         if rem(round(time/2),5)>0
%             yr=rem(round(time/2),5);
%         else
%             yr=5;
%         end
        if rem(year,5)>0
            yr=rem(year,5);
        else
            yr=5;
        end
    case 3%use a random yearly matrix
        yr=randi(5);
        
%     case 4%use yearly matrix based on predetermined probabiltiy for rainfall etc
%         prob=rand;
%         yr=;%find rpboability of using yearly matrices

end

%for now, this uses the same matrix for all 6 coral types
coral_connectivity.matrix = ACROCNS(yr).M ; 
coral_connectivity(2).matrix = ACROCNS(yr).M ; 
coral_connectivity(3).matrix = ACROCNS(yr).M ; 
coral_connectivity(4).matrix = ACROCNS(yr).M ; 
coral_connectivity(5).matrix = ACROCNS(yr).M ; 
coral_connectivity(6).matrix = ACROCNS(yr).M ;

cots_connectivity.matrix = COTSCNS(yr).cmlpld ; 



end

