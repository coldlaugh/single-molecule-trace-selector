for expt = 1 : 10
    for condition = 1 : 2
        exptFolder = strcat('../experiments/experiment',num2str(condition),'-',num2str(expt),'/');
        train_RNN_segment_func(exptFolder);
    end
end
system('shutdown -s')