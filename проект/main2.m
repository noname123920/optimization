clear all; close all; clc

% Координаты
xG = 10;   yG = 2;    % Девочка в воде (выше границы)
xB = 0;    yB = -2;   % Мальчик в песке (ниже границы)

% Граница раздела вода/песок (горизонтальная линия)
y_boundary = 0;

% Скорости
v_water = 3.0;    % скорость в воде
v_sand  = 1.0;    % скорость в песке

figure(1);
hold on; grid on; axis equal;

% 1. Рисуем воду (верхняя половина)
water_color = [0.7 0.9 1.0]; % светло-голубой
fill([-2, 12, 12, -2], [0, 0, 4, 4], water_color, 'EdgeColor', 'none');

% 2. Рисуем песок (нижняя половина)
sand_color = [1.0 0.9 0.7]; % светло-коричневый
fill([-2, 12, 12, -2], [0, 0, -4, -4], sand_color, 'EdgeColor', 'none');

% 3. Граница раздела (берег)
plot([-2, 12], [0, 0], 'k-', 'LineWidth', 3);

% 4. Мальчик (синий закрашенный круг внизу)
boy_radius = 0.3;
theta = linspace(0, 2*pi, 100);
x_boy = xB + boy_radius * cos(theta);
y_boy = yB + boy_radius * sin(theta);
boy_handle = fill(x_boy, y_boy, 'b');

% 5. Девочка (красный закрашенный круг вверху)
girl_radius = 0.3;
x_girl = xG + girl_radius * cos(theta);
y_girl = yG + girl_radius * sin(theta);
girl_handle = fill(x_girl, y_girl, [1 0.7 0.8]);

% Функция времени
T = @(x) sqrt((xB - x)^2 + yB^2) / v_sand + sqrt((xG - x)^2 + yG^2) / v_water;

% Вычислим время для нескольких точек на границе
test_points = [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
fprintf('\nВремя пути для разных точек на границе \n');
fprintf('x\tT(x)\n');
fprintf('----------------\n');
for i = 1:length(test_points)
    x_test = test_points(i);
    fprintf('%.1f\t%.4f\n', x_test, T(x_test));
end

% Найдем точку с минимальным временем (перебором)
[min_time, min_idx] = min(arrayfun(T, test_points));
x_approx = test_points(min_idx);
fprintf('\nПриближенный минимум (перебором):\n');
fprintf('x* ≈ %.1f, T_min ≈ %.4f\n', x_approx, min_time);

% Производная функции времени
dT = @(x) -(xB - x) / (v_sand * sqrt((xB - x)^2 + yB^2)) ...
          -(xG - x) / (v_water * sqrt((xG - x)^2 + yG^2));

% Вторая производная функции времени
ddT = @(x) yB^2 / (v_sand * ((xB - x)^2 + yB^2)^(3/2)) ...
         + yG^2 / (v_water * ((xG - x)^2 + yG^2)^(3/2));

% Задаем параметры решения
epsilon = 1e-6;
x0 = x_approx;

% Инициализируем переменные
x_prev = x0;
difference = 1;
iter = 0;

% Печатаем заголовок таблицы
fprintf('\nМетод Ньютона:\n');
fprintf('№ итерации |    Корень    |   Разность   |  Точность ε\n');
fprintf('-----------|--------------|--------------|-------------\n');

% Метод Ньютона с циклом while
while difference > epsilon
    x_next = x_prev - dT(x_prev) / ddT(x_prev);

    iter = iter + 1;
    difference = abs(x_next - x_prev);

    % Выводим результаты текущей итерации в таблицу
    fprintf('%10d | %12.6f | %12.6f | %12.6f\n', iter, x_next, difference, epsilon);

    x_prev = x_next;
end

% Оптимальная точка на границе (берегу)
x_opt = x_prev;

% Выводим итоговый результат
fprintf('\nИтоговый результат:\n');
fprintf('Оптимальная точка перехода: x* = %.6f\n', x_opt);
fprintf('Минимальное время пути: T_min = %.6f\n', T(x_opt));
fprintf('Количество итераций: %d\n', iter);

% Координаты траектории: (xB, yB) -> (x_opt, 0) -> (xG, yG)
traj_x = [xB, x_opt, xG];
traj_y = [yB, 0, yG];

% 6. Рисуем оптимальную траекторию
traj_handle = plot(traj_x, traj_y, 'r--', 'LineWidth', 2);

% 7. Отмечаем точку пересечения границы
point_handle = plot(x_opt, 0, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8);

% Создаем элементы для легенды
water_patch = patch(NaN, NaN, water_color, 'EdgeColor', 'none');
sand_patch = patch(NaN, NaN, sand_color, 'EdgeColor', 'none');
boundary_handle = plot(NaN, NaN, 'k-', 'LineWidth', 2);

% Добавляем легенду со всеми элементами
legend([boy_handle, girl_handle, point_handle, traj_handle, water_patch, sand_patch, boundary_handle], ...
       {'Мальчик (xB=0, yB=-2)', ...
        'Девочка (xG=10, yG=2)', ...
        sprintf('Точка перехода (x*=%.3f)', x_opt), ...
        'Оптимальная траектория', ...
        sprintf('Вода (v=%.1f)', v_water), ...
        sprintf('Песок (v=%.1f)', v_sand), ...
        'Граница вода/песок'}, ...
       'Location', 'northwest', 'FontSize', 10, 'Box', 'off');

% Настройка графика
xlim([-2, 12]);
ylim([-4, 4]);
xlabel('X координата', 'FontSize', 12);
ylabel('Y координата', 'FontSize', 12);

% Увеличиваем шрифт на осях
set(gca, 'FontSize', 11);



% Дополнительная информация в консоль
fprintf('\n=== ПАРАМЕТРЫ ЗАДАЧИ ===\n');
fprintf('Скорость в воде: %.1f\n', v_water);
fprintf('Скорость в песке: %.1f\n', v_sand);
fprintf('Координаты мальчика: (%.1f, %.1f)\n', xB, yB);
fprintf('Координаты девочки: (%.1f, %.1f)\n', xG, yG);
fprintf('\n=== ГЕОМЕТРИЧЕСКИЕ ПАРАМЕТРЫ ===\n');
fprintf('Длина пути в песке: %.4f\n', sqrt((xB - x_opt)^2 + yB^2));
fprintf('Длина пути в воде: %.4f\n', sqrt((xG - x_opt)^2 + yG^2));
fprintf('Полная длина пути: %.4f\n', sqrt((xB - x_opt)^2 + yB^2) + sqrt((xG - x_opt)^2 + yG^2));
