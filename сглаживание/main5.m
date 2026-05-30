a = 0;
b = 1;
h = 0.01;
delta = 0.01;
x = a:h:b;
s = a:h:b;
N = length(x)

const = 0.5 * (1 - exp(-2));

A = zeros(N, N);
for j = 1:N
  for i = 1:N
    K_val = const * exp(-(x(j) + s(i)));
    A(j, i) = h * K_val;
  end
end

z_true = @(s) s;

u = zeros(N, 1);
for j = 1:N
  sum_val = 0;
  for i = 1:N
    K_val = const * exp(-(x(j) + s(i)));
    sum_val = sum_val + K_val * z_true(s(i));
  end
  u(j) = h * sum_val + delta * rand;
end

z_numeric = A \ u;

z_exact = s';

figure;
plot(s, z_exact, 'b-', 'LineWidth', 2);
hold on;
plot(s, z_numeric, 'ro--', 'LineWidth', 1.5);
xlabel('s');
ylabel('z(s)');
grid on;
