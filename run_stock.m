function [stock f_surface] = run_stock(p, prev, i, Z)

  if isempty(prev.S(i).f_surface)    
    if isempty(p.S(i).fixedSigma)
      % calulate local vol surface
      surface = local_vol_surface(p.S(i), p.r);
      f_surface = @(t,s) local_vol(surface, t, s);
    else
      % use a constant vol surface
      f_surface = @(t,s) p.S(i).fixedSigma;
    end
  else
      f_surface = prev.S(i).f_surface;
  end

  stock = euler_simulation(p.S(i).x_0, p.T, f_surface, Z, p.r);
end

% from: run_put
function sigma = local_vol(surface, t, s)
    t_index = floor(t / surface.dT);
    s_index = floor(s / surface.dK);
    
    % clamp our volatility on the bottom and top level
    t_index(t_index < 1) = 1;
    t_index(t_index > numel(surface.maturities)) = numel(surface.maturities);
    s_index(s_index < 1) = 1;
    s_index(s_index > numel(surface.strikes)) = numel(surface.strikes);

    sigma = surface.surface(t_index, s_index)';
end