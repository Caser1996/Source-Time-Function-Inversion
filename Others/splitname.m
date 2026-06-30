function tokens = splitname(rawname)
%{
    This porgram is used to sperate the string by seperator:
    ['.', '/', '-', '_', ' ', etc.]
%}
    tokens = cell(1,0);
    start = 1;  
    for i = 1:length(rawname)  
        if rawname(i) == '_' || rawname(i) == '.'  || rawname(i) == '/'  || rawname(i) == '-'  || rawname(i) == ' '  
            if start ~= i  
                tokens = [tokens; rawname(start:i-1)];  
            end  
            start = i+1;  
        end  
    end  
      
    % add the last element
    if start ~= length(rawname)+1  
        tokens = [tokens; rawname(start:end)];  
    end  
      
    % result display
%     disp(tokens);
    