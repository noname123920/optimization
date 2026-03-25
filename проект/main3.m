dt = 0.1;
T = 5;
u = 2;

u_history = [u];
t_history = [0];

figure;
grid on;
xlabel('t, c');
ylabel('u(t)');
xlim([0, T]);
ylim([-2.5, 2.5]);
hold on;

n = 1;
while n * dt <= T
    if u > 0
        f = -1;
    else
        f = 1;
    endif

    u = u + dt * f;

    u_history = [u_history, u];
    t_history = [t_history, n * dt];

    % Анимация
    plot(t_history, u_history, 'b-', 'LineWidth', 4);
    drawnow;
    pause(0.05);

    n = n + 1;
endwhile

hold off;
