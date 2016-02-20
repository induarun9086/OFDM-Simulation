function[p,q]=butterfly(x,y)
    % Add the sequences for even values
    p=x+y;
    % Subtract the sequences for odd values 
    q=x-y;
end