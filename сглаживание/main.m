clc; clear; close all;

% Параметры
a = 0; b = 1; h = 0.1; alpha = 1; delta = 0;  % шум пока уберём
n = round((b - a) / h);
N = n + 1;           % N = 11
s = (a:h:b)';        % узлы 0,0.1,...,1

% Ядро
K = @(s,t) (1/2)*(1 - exp(-2)) * exp(-(s+t));

% Матрица C (оператор -u'' + u, граничные условия)
C = zeros(N,N);
for i = 2:N-1
    C(i,i-1) = -alpha/h^2;
    C(i,i)   = alpha * (1 + 2/h^2);
    C(i,i+1) = -alpha/h^2;
end
C(1,1) = 1; C(1,2) = 0;
C(N,N-1) = 0; C(N,N) = 1;

% Матрица B_full (полная, без обнулений)
B_full = zeros(N,N);
for i = 1:N
    for j = 1:N
        B_full(i,j) = h * K(s(i), s(j));
    end
end

% Модифицированная B для системы: строки 1 и N обнулены,
% столбцы НЕ обнуляем, т.к. в U уже учтён вклад граничных u (оба =0)
B_mod = B_full;
B_mod(1,:) = 0;
B_mod(N,:) = 0;

% Эталонное решение u_exact = x (или любое другое)
u_exact = s;   % [0; 0.1; 0.2; ...; 1.0]

% Формируем правую часть U
U = zeros(N,1);
U(2:N-1) = B_full(2:N-1, :) * u_exact;   % матричное умножение: h*Sum_j K(s_i,s_j) u_j
U(1) = 0;
U(N) = 0;

% Решаем систему
A = C + B_mod;
z = A \ U;

% Погрешность
err = max(abs(z - u_exact));
fprintf('Максимальная погрешность |z - u_exact| = %e\n', err);

% График
figure;
plot(s, u_exact, 'b-', 'LineWidth', 2); hold on;
plot(s, z, 'ro--');
legend('u_{exact} = x', 'z (решение)');
xlabel('x'); ylabel('u');
title('Решение (C+B)z = U, U = [0; (B_{full}u_{ex})_{inner}; 0]');
grid on;

