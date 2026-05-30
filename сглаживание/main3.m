graphics_toolkit('gnuplot')
format free

a = 0;
b = 1;
h = 0.04;
alpha = 0.03;

N = round((b - a) / h) + 1;
s = linspace(a, b, N);

z_exact = s;

C = zeros(N, N);
B = zeros(N, N);
U = zeros(N, 1);

% Матрица C (стабилизатор)
for i = 2 : N-1
    C(i, i-1) = -alpha / h^2;
    C(i, i)   = alpha * (1 + 2/h^2);
    C(i, i+1) = -alpha / h^2;
end
C(1, 1) = 1;
C(1, 2) = -1;
C(N, N-1) = -1;
C(N, N)   = 1;

% Матрица B (дискретизация ядра)
for i = 2 : N-1
    for j = 1 : N
        B(i, j) = h * exp(-(s(i) + s(j)));
    end
end
B(:, N) = 0;
B(1, :) = 0;
B(N, :) = 0;

% Вектор правой части U
U(1) = 0;
U(N) = 0;
for i = 2 : N-1
    sum_val = 0;
    for j = 1 : N
        sum_val = sum_val + h * exp(-(s(i) + s(j))) * z_exact(i);
    end
    U(i) = sum_val;
end

% Решение системы (B + C) * z = U
M = C + B;
z = M \ U;

% График
plot(s, z,'LineWidth', 2);
hold on;
plot(s, z_exact);
grid on;
xlabel('s');
ylabel('z(s)');
legend('Приближенное решение', 'Точное решение', 'Location', 'best');
hold off;
