function [out, dt, du] = Hstar_func(t,x)
global T
T = 1400;
g = [zeros(3); eye(3)];

[M1star, h_of_M1star, dM1star_dx] = find_max(t,x);

if h_of_M1star <= 0
    R = M1star;
    dR_dx = dM1star_dx;
else
    [R, dR_dx] = find_zero(M1star, t, x);
    if norm(dR_dx) >= 10*norm(dM1star_dx)
        % Assume forward differentiability. Switch to M1star when the derivative gets too large
        dR_dx = dM1star_dx;
    end
end

[m, dm] = m_func(R - t);
out = h_of_M1star - m;

[~, ~, dh_of_tau_dx] = h_func(M1star, path_func(M1star,t,x));
[~, ~, ~, dp_of_tau_dx] = path_func(M1star,t,x);

if nargout > 1
    if M1star <= t + 1
        % Case iii
        delta = 1;
        dh_dtau = (h_func(M1star+delta, path_func(M1star+delta,t,x)) - h_of_M1star)/delta;
        % Since the system is of high relative degree, dtau_dt = 1 is always guaranteed
        dt = dh_dtau*1;
        du = dh_of_tau_dx*dp_of_tau_dx*g;
    elseif M1star < t+T
        % Case i
        dt = dm;
        du = (dh_of_tau_dx*dp_of_tau_dx - dm*dR_dx)*g;
    elseif M1star <= t + T + 1
        if h_of_M1star > 0
            % Case ii
            delta = 1;
            dh_dtau = (h_func(M1star+delta, path_func(M1star+delta,t,x)) - h_of_M1star)/delta;
            % Assume dtau_dt = 1 for simplicity
            dt = dm + dh_dtau*1;
            du = (dh_of_tau_dx*dp_of_tau_dx - dm*dR_dx)*g;
        else
            % Case iii
            delta = 1;
            dh_dtau = (h_func(M1star+delta, path_func(M1star+delta,t,x)) - h_of_M1star)/delta;
            % Assume dtau_dt = 1 for simplicity
            dt = dh_dtau*1;
            du = dh_of_tau_dx*dp_of_tau_dx*g;
        end
    else
        disp('Something went wrong. M1star > t+T');
    end
end

end

function [out, dlambda] = m_func(lambda)
global T
t_m = 150;
if lambda < t_m
    out = 0;
    dlambda = 0;
else
    dt = lambda - t_m;
    m = 16/((T-t_m)^2);
    out = m*dt^2;
    dlambda = 2*m*dt;
end
end