mp.Fs = 48000; %sample rate
mp.Ts = 1/mp.Fs;
mp.Fs_system = 98.304* 1000000;
mp.oversampling_factor = mp.Fs_system/mp.Fs;
mp.target_Frequency = mp.Fs_system / 1000000;

mp.W_bits = 24;
mp.F_bits = 23;

mp.W_gain = 16;
mp.F_gain = mp.W_gain - 1;

max_delay_time = 2; %unit is seconds
max_delay_samples = max_delay_time * mp.Fs;
max_delay_memory_bits = max_delay_samples * mp.W_bits;

mp.DPRAM1_address_size = floor(log2(max_delay_samples));
mp.DPRAM1_size = 2^(mp.DPRAM1_address_size);

memory_size = mp.DPRAM1_size*mp.W_bits*2;
memory_available = 5530000;
if memory_size > memory_available
        error('Will not fit in cyclone 5')
end


mp.control_delay.value = 10000;
mp.control_delay.bin_string = fi(mp.control_delay.value,0,mp.DPRAM1_address_size,0).bin;
disp(['Initilization string for delay signal = ' mp.control_delay.bin_string])

mp.control_gain.value = .75;
mp.control_gain.bin_string = fi(mp.control_gain.value,0,mp.W_gain,mp.F_gain).bin;
mp.control_enable.value = 1;

[signal1,Fs1] = audioread('acoustic.wav'); %get audio and put in timeseries
%Fs = 48000;
%Ts = 1/Fs;
signal2 = resample(signal1,mp.Fs,Fs1);
signal3 = signal2* .95;
timevals = [0:length(signal3)-1]*mp.Ts;
mp.input_timeseries = timeseries(signal2,timevals);

%stop_time = timevals(end);
stop_time = 100*mp.Ts;