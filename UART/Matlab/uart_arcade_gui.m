% =========================================================================
% UART Arcade Oscilloscope & Interference Engine (Phase 1 & 2 Ready)
% Owner: Vamseedhar | Baud: 115,200 (8N1) | Packet: [0xFF][SigA][SigB][XOR]
% =========================================================================
clear; clc; close all;

%% 1. CONFIGURATION & MODE TOGGLE
SIMULATION_MODE = true;   % Set true for Phase 1 standalone test (Fake Packet Gen)
                          % Set false for Phase 2 live COM11 + COM4 integration
PORT_VERILOG = "COM11";   % Virtual COM port from Python/Verilog bridge
PORT_ARDUINO = "COM4";    % Physical COM port to/from Arduino Uno
BAUD_RATE    = 115200;

SAMPLES_PER_PERIOD = 64;  % 64 samples/period -> 5.625 deg per sample
PLOT_WINDOW        = 256; % 4 wave periods displayed on screen
BATCH_SIZE         = 16;  % Process 16 packets per GUI frame (~60 FPS at 1000 pkt/s)

%% 2. STATE BUFFERS & CIRCULAR DELAY LINE
buf_SigA      = repmat(127, 1, PLOT_WINDOW);
buf_SigB      = repmat(127, 1, PLOT_WINDOW);
buf_Superpos  = zeros(1, PLOT_WINDOW);

% 64-sample circular buffer for delaying Signal B
circ_buf_B    = repmat(127, 1, SAMPLES_PER_PERIOD);
write_ptr     = 1;
phase_delay   = 0;        % 0 to 63 samples (0 deg = 0, 180 deg = 32)

% Audio cue synthesis (8 kHz sample rate)
fs_audio = 8000;
t_sound  = 0:(1/fs_audio):0.25;
snd_powerup  = 0.4 * sin(2*pi*523.25*t_sound) + 0.4 * sin(2*pi*659.25*t_sound);
snd_flatline = 0.5 * sin(2*pi*980*t_sound);
last_audio_state = "";

%% 3. BUILD ARCADE GUI
fig = figure('Name', 'HAM-ARC UART Wave Interference Arcade', ...
             'Color', [0.06 0.06 0.09], 'Position', [100, 100, 1050, 680]);

ax1 = subplot(2, 1, 1);
hold(ax1, 'on');
h_sigA = plot(ax1, 1:PLOT_WINDOW, buf_SigA, 'Color', [0.0 0.9 1.0], 'LineWidth', 2.0, 'DisplayName', 'Signal A (System Fixed)');
h_sigB = plot(ax1, 1:PLOT_WINDOW, buf_SigB, 'Color', [1.0 0.5 0.0], 'LineWidth', 2.0, 'LineStyle', '--', 'DisplayName', 'Signal B (Knob Shifted)');
yline(ax1, 127, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
set(ax1, 'Color', [0.1 0.1 0.14], 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.3 0.3 0.3]);
grid(ax1, 'on'); xlim(ax1, [1 PLOT_WINDOW]); ylim(ax1, [-10 265]);
ylabel(ax1, 'Amplitude (0 - 254)', 'Color', 'w', 'FontWeight', 'bold');
title_ax1 = title(ax1, 'DUAL-CHANNEL UART TELEMETRY | Phase Shift: 0.0 deg (0 samples)', 'Color', 'w', 'FontSize', 12);
legend(ax1, 'TextColor', 'w', 'Color', [0.15 0.15 0.2], 'Location', 'northeast');

ax2 = subplot(2, 1, 2);
hold(ax2, 'on');
h_diff = plot(ax2, 1:PLOT_WINDOW, buf_Superpos, 'Color', [0.2 1.0 0.4], 'LineWidth', 2.2);
yline(ax2, 0, '--', 'Color', [0.6 0.6 0.6]);
set(ax2, 'Color', [0.1 0.1 0.14], 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.3 0.3 0.3]);
grid(ax2, 'on'); xlim(ax2, [1 PLOT_WINDOW]); ylim(ax2, [-270 270]);
xlabel(ax2, 'Sample Window (256 Samples = 4 Periods @ 15.6 Hz)', 'Color', 'w', 'FontWeight', 'bold');
ylabel(ax2, 'Interference (A + B_{shifted})', 'Color', 'w', 'FontWeight', 'bold');

banner_txt = text(ax2, PLOT_WINDOW/2, 200, 'SCANNING PHASE...', ...
    'Color', 'w', 'FontSize', 15, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'BackgroundColor', [0.2 0.2 0.25], 'EdgeColor', 'w');

%% 4. SERIAL PORT INITIALIZATION (If Live Mode)
if ~SIMULATION_MODE
    s_verilog = serialport(PORT_VERILOG, BAUD_RATE, "Timeout", 1);
    s_arduino = serialport(PORT_ARDUINO, BAUD_RATE, "Timeout", 1);
    flush(s_verilog); flush(s_arduino);
end

%% 5. MAIN REAL-TIME PROCESSING LOOP
sim_sample_idx = 0;
frame_counter  = 0;

while ishandle(fig)
    frame_counter = frame_counter + 1;
    
    if SIMULATION_MODE
        if mod(frame_counter, 45) == 0
            phase_delay = mod(phase_delay + 4, SAMPLES_PER_PERIOD);
        end
        raw_bytes = zeros(1, BATCH_SIZE * 4, 'uint8');
        for k = 1:BATCH_SIZE
            theta = 2 * pi * sim_sample_idx / SAMPLES_PER_PERIOD;
            % Scaled Sine matching Zikra's DDS hardware ROM [12, 242]
            valA = uint8(round(127 + 115 * sin(theta)));
            % Secondary wave matching hardware: Square Wave toggling [254, 0]
            if mod(sim_sample_idx, SAMPLES_PER_PERIOD) < (SAMPLES_PER_PERIOD / 2)
                valB = uint8(254);
            else
                valB = uint8(0);
            end
            % Alternative sine wave option:
            % valB = uint8(round(127 + 115 * sin(theta)));
            chk  = bitxor(valA, valB);
            idx = (k-1)*4 + 1;
            raw_bytes(idx:idx+3) = [uint8(255), valA, valB, chk];
            sim_sample_idx = sim_sample_idx + 1;
        end
    else
        if s_arduino.NumBytesAvailable > 0
            ard_bytes = read(s_arduino, s_arduino.NumBytesAvailable, "uint8");
            phase_delay = min(double(ard_bytes(end)), SAMPLES_PER_PERIOD - 1);
        end
        if s_verilog.NumBytesAvailable < 4
            pause(0.002); continue;
        end
        n_read = min(s_verilog.NumBytesAvailable, BATCH_SIZE * 4);
        raw_bytes = read(s_verilog, n_read, "uint8");
    end
    
    i = 1;
    while i <= (length(raw_bytes) - 3)
        if raw_bytes(i) == 255
            sigA = double(raw_bytes(i+1));
            sigB = double(raw_bytes(i+2));
            rx_chk = raw_bytes(i+3);
            
            if (sigA < 255) && (sigB < 255) && (rx_chk == bitxor(uint8(sigA), uint8(sigB)))
                circ_buf_B(write_ptr) = sigB;
                read_ptr = mod(write_ptr - phase_delay - 1, SAMPLES_PER_PERIOD) + 1;
                sigB_shifted = circ_buf_B(read_ptr);
                write_ptr = mod(write_ptr, SAMPLES_PER_PERIOD) + 1;
                
                buf_SigA     = [buf_SigA(2:end), sigA];
                buf_SigB     = [buf_SigB(2:end), sigB_shifted];
                buf_Superpos = [buf_Superpos(2:end), (sigA - 127) + (sigB_shifted - 127)];
                
                if ~SIMULATION_MODE
                    tx_chk = bitxor(uint8(sigA), uint8(sigB_shifted));
                    write(s_arduino, [uint8(255), uint8(sigA), uint8(sigB_shifted), tx_chk], "uint8");
                end
                i = i + 4;
            else
                i = i + 1;
            end
        else
            i = i + 1;
        end
    end

    set(h_sigA, 'YData', buf_SigA);
    set(h_sigB, 'YData', buf_SigB);
    set(h_diff, 'YData', buf_Superpos);
    
    deg_shift = phase_delay * (360 / SAMPLES_PER_PERIOD);
    set(title_ax1, 'String', sprintf('DUAL-CHANNEL UART TELEMETRY | Knob Delay: %d samples (%.2f deg)', phase_delay, deg_shift));
    
    if phase_delay == 0
        set(h_diff, 'Color', [0.0 1.0 1.0]);
        set(banner_txt, 'String', 'POWER BAR: MAX CONSTRUCTIVE RESONANCE (0 deg)', ...
            'BackgroundColor', [0.0 0.45 0.75], 'Color', 'w');
        if last_audio_state ~= "POWER"
            sound(snd_powerup, fs_audio);
            last_audio_state = "POWER";
        end
    elseif phase_delay == 32
        set(h_diff, 'Color', [1.0 0.15 0.15]);
        set(banner_txt, 'String', 'FLATLINE! TOTAL ANNIHILATION! (180 deg)', ...
            'BackgroundColor', [0.75 0.05 0.05], 'Color', 'y');
        if last_audio_state ~= "FLATLINE"
            sound(snd_flatline, fs_audio);
            last_audio_state = "FLATLINE";
        end
    else
        set(h_diff, 'Color', [0.2 1.0 0.4]);
        set(banner_txt, 'String', sprintf('INTERFERENCE ACTIVE | Phase Offset: %.2f deg', deg_shift), ...
            'BackgroundColor', [0.2 0.2 0.25], 'Color', 'w');
        last_audio_state = "NORMAL";
    end
    
    drawnow limitrate;
    if SIMULATION_MODE
        pause(0.03);
    end
end
