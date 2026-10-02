function [tx_signal, z] = construct_virtual_mimo(frame, alpha)
% CONSTRUCT_VIRTUAL_MIMO Structures payload for 2-slot time division and adds AN
%
% Inputs:
%   frame - The baseband signal frame (pilot + data)
%   alpha - Noise scaling factor
%
% Outputs:
%   tx_signal - Stacked signal containing Slot 1 and Slot 2
%   z - The generated artificial noise added to the signal
%
% Concept:
% Virtual MIMO transmits the same structure in two time slots
% Slot 1: y1 = h1*(s + alpha*z1) + n1  (Simplified: just s + alpha*z1)
% Slot 2: y2 = h2*(s + alpha*z2) + n2  (Simplified: just s + alpha*z2)
% Wait, standard Virtual MIMO with AN in this context:
% We transmit x1 = s + alpha*z1 in slot 1, x2 = s + alpha*z2 in slot 2.
% We can just use the same s, but different AN realizations.

    len = length(frame);
    
    % Slot 1: s + alpha*z
    z1 = generate_artificial_noise(len, alpha);
    x1 = frame + z1;
    
    % Slot 2: s - alpha*z (allows Bob to cancel noise by simple combining)
    x2 = frame - z1;
    
    % Stack them temporally (one after another)
    tx_signal = [x1; x2];
    
    % Return noise for reference
    z = [z1; -z1];
end
