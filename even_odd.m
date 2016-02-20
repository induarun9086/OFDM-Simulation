function[p,q]=even_odd(x)

    % Split the sequences into odd and even
    [m,N]=size(x);
    p=zeros(N/2);
    q=zeros(N/2);
    
    % p -> Odd seuences
    p=x(1:2:N);
    % q -> Even seuences
    q=x(2:2:N);
end