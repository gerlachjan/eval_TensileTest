function [strain_true,stress_true] = true_values(stress,strain,E)

%calculation of elastic strain
e_e = stress/E;
e_p = strain - e_e;

strain_true = log(1+e_p);
stress_true = stress.*(1+strain);
end
