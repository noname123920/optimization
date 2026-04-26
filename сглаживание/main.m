clc;

a = 0; b = 1; h = 0.05; alpha = 1;

C = create_matrix(alpha, h, a, b);

n = round((b - a) / h);
i = 0:n;
s = a + i * h;

z_ex = (i * h)';
b_vec = C * z_ex;
z_new = C \ b_vec;
err = max(abs(z_ex - z_new));

figure;
plot(s, z_new);
grid on;
xlabel('s');
ylabel('z');
