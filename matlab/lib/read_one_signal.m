function x = read_one_signal(path)
    formatSpec = '%f';
    
    f = fopen(path,'r');
    x = fscanf(f,formatSpec);
    x = normc(x);
    fclose(f);
end