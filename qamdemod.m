function y=qamdemod(x)
[m,n]= size(x);
y=zeros(1,n);

for i=1:1:n
    % Iterate the seqence and apply demodulation for each value
   y(i)= qamdemap(x(i)); 
end

end