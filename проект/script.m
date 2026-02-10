%% ===== ШАГ 1: Задаем параметры =====
clear all; close all; clc;

% Координаты
xA = 10;   yA = 2;    % Девочка в воде (выше границы)
xB = 0;  yB = -2;   % Мальчик в песке (ниже границы)

% Граница раздела вода/песок (горизонтальная линия)
y_boundary = 0;

% Скорости (пусть в воде быстрее, в песке медленнее)
v_water = 3.0;    % скорость в воде
v_sand  = 1.0;    % скорость в песке

% Пока просто выведем параметры
fprintf('Точка A (девочка): (%.1f, %.1f)\n', xA, yA);
fprintf('Точка B (мальчик): (%.1f, %.1f)\n', xB, yB);
fprintf('Граница: y = %.1f\n', y_boundary);
fprintf('Скорость в воде: %.1f\n', v_water);
fprintf('Скорость в песке: %.1f\n', v_sand);

%% ===== ШАГ 2: Рисуем схему (мальчик слева, девочка справа) =====
figure(1);
hold on; grid on; axis equal;

% Меняем координаты местами
xA = 10;   yA = 2;    % Девочка в воде СПРАВА
xB = 0;    yB = -2;   % Мальчик в песке СЛЕВА

% 1. Рисуем воду (верхняя половина)
water_color = [0.7 0.9 1.0]; % светло-голубой
fill([-2, 12, 12, -2], [0, 0, 4, 4], water_color, 'EdgeColor', 'none');

% 2. Рисуем песок (нижняя половина)
sand_color = [1.0 0.9 0.7]; % светло-коричневый
fill([-2, 12, 12, -2], [0, 0, -4, -4], sand_color, 'EdgeColor', 'none');

% 3. Граница раздела (берег)
plot([-2, 12], [0, 0], 'k-', 'LineWidth', 3);

% 4. Точки A и B (теперь A справа, B слева)
plot(xA, yA, 'bo', 'MarkerSize', 15, 'LineWidth', 3, 'MarkerFaceColor', 'b');
plot(xB, yB, 'go', 'MarkerSize', 15, 'LineWidth', 3, 'MarkerFaceColor', 'g');

% 5. Подписи
text(xA, yA+0.3, 'Девочка (A)', 'FontSize', 12, 'HorizontalAlignment', 'center');
text(xB, yB-0.3, 'Мальчик (B)', 'FontSize', 12, 'HorizontalAlignment', 'center');
text(5, 2.5, 'ВОДА', 'FontSize', 14, 'HorizontalAlignment', 'center');
text(5, -2.5, 'ПЕСОК', 'FontSize', 14, 'HorizontalAlignment', 'center');

% Настройки графика
xlabel('x'); ylabel('y');
title('Схема: мальчик слева в песке, девочка справа в воде');
xlim([-2, 12]); ylim([-4, 4]);

% Обновляем вывод параметров
fprintf('=== Обновленные координаты ===\n');
fprintf('Девочка (A) справа в воде: (%.1f, %.1f)\n', xA, yA);
fprintf('Мальчик (B) слева в песке: (%.1f, %.1f)\n', xB, yB);
fprintf('Граница: y = %.1f\n', y_boundary);

%% ===== ШАГ 3: Функция времени пути =====
% T(x) = расстояние_в_воде / v_water + расстояние_в_песке / v_sand
% где x - координата точки на границе (y = y_boundary)

% Функция времени пути
T = @(x) sqrt((x - xA)^2 + (y_boundary - yA)^2)/v_water + ...
         sqrt((xB - x)^2 + (yB - y_boundary)^2)/v_sand;

% Давайте вычислим время для нескольких точек на границе
test_points = [-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
fprintf('\n=== Время пути для разных точек на границе ===\n');
fprintf('x\tT(x) (время)\n');
fprintf('----------------\n');
for i = 1:length(test_points)
    x_test = test_points(i);
    fprintf('%.1f\t%.4f\n', x_test, T(x_test));
end

% Найдем точку с минимальным временем (грубо, перебором)
[min_time, min_idx] = min(arrayfun(T, test_points));
x_approx = test_points(min_idx);
fprintf('\nПриближенный минимум (перебором):\n');
fprintf('x* ≈ %.1f, T_min ≈ %.4f\n', x_approx, min_time);

%% ===== ШАГ 4: Метод Ньютона =====
% Производная функции времени T'(x)
dT = @(x) (x - xA)/(v_water * sqrt((x - xA)^2 + (y_boundary - yA)^2)) ...
         - (xB - x)/(v_sand * sqrt((xB - x)^2 + (yB - y_boundary)^2));

% Вторая производная T''(x) для метода Ньютона
d2T = @(x) 1/(v_water * sqrt((x - xA)^2 + (y_boundary - yA)^2)) ...
          - (x - xA)^2/(v_water * ((x - xA)^2 + (y_boundary - yA)^2)^(3/2)) ...
          + 1/(v_sand * sqrt((xB - x)^2 + (yB - y_boundary)^2)) ...
          - (xB - x)^2/(v_sand * ((xB - x)^2 + (yB - y_boundary)^2)^(3/2));

% Начальное приближение (из нашего перебора)
x0 = x_approx; % начинаем с x ≈ 1.0

% Параметры метода
max_iter = 20;
tolerance = 1e-8;

fprintf('\n=== Метод Ньютона ===\n');
fprintf('Начальное приближение: x0 = %.4f\n', x0);
fprintf('Итерация\tx\t\tT(x)\t\tdT(x)\t\tПогрешность\n');
fprintf('----------------------------------------------------------------\n');

x_opt = x0;
for iter = 1:max_iter
    f_val = dT(x_opt);
    f_prime = d2T(x_opt);

    % Проверка деления на ноль
    if abs(f_prime) < 1e-12
        fprintf('Вторая производная слишком мала!\n');
        break;
    end

    % Формула Ньютона: x_new = x - f(x)/f'(x)
    x_new = x_opt - f_val/f_prime;

    error = abs(x_new - x_opt);

    fprintf('%2d\t\t%.8f\t%.6f\t%.6e\t%.2e\n', ...
            iter, x_opt, T(x_opt), f_val, error);

    % Критерий остановки
    if error < tolerance
        fprintf('\nДостигнута точность! Погрешность < %.0e\n', tolerance);
        break;
    end

    x_opt = x_new;

    if iter == max_iter
        fprintf('\nДостигнуто максимальное число итераций\n');
    end
end

fprintf('\nОптимальная точка: x* = %.8f\n', x_opt);
fprintf('Минимальное время: T_min = %.8f\n', T(x_opt));


%% ===== ШАГ 5: Проверка закона Снеллиуса =====
x_star = x_opt;  % оптимальная точка

% Расстояния и углы:
% В воде: от A до X*
dx_water = x_star - xA;
dy_water = y_boundary - yA;  % отрицательное (вниз)
dist_water = sqrt(dx_water^2 + dy_water^2);

% В песке: от X* до B
dx_sand = xB - x_star;
dy_sand = yB - y_boundary;   % отрицательное (вниз)
dist_sand = sqrt(dx_sand^2 + dy_sand^2);

% Синусы углов (по модулю, так как нас интересуют абсолютные значения)
sin_alpha = abs(dy_water) / dist_water;  % sin(α)
sin_beta = abs(dy_sand) / dist_sand;     % sin(β)

% По закону Снеллиуса: sin(α)/v1 = sin(β)/v2
left_side = sin_alpha / v_water;
right_side = sin_beta / v_sand;

fprintf('\n=== Проверка закона Снеллиуса ===\n');
fprintf('Расстояние в воде:  %.6f\n', dist_water);
fprintf('Расстояние в песке: %.6f\n', dist_sand);
fprintf('sin(α) = %.6f, sin(β) = %.6f\n', sin_alpha, sin_beta);
fprintf('sin(α)/v_воды = %.6f\n', left_side);
fprintf('sin(β)/v_песка = %.6f\n', right_side);
fprintf('Разница: %.10f\n', abs(left_side - right_side));

if abs(left_side - right_side) < 1e-6
    fprintf('✓ Закон Снеллиуса выполняется!\n');
else
    fprintf('✗ Небольшая погрешность\n');
end

% Вычисляем сами углы в градусах для наглядности
alpha_deg = asind(sin_alpha);  % угол падения
beta_deg = asind(sin_beta);    % угол преломления
fprintf('\nУглы:\n');
fprintf('α (в воде) = %.2f°\n', alpha_deg);
fprintf('β (в песке) = %.2f°\n', beta_deg);


%% ===== ШАГ 6: Рисуем оптимальную траекторию =====
figure(2);
hold on; grid on; axis equal;

% 1. Рисуем среды
fill([-2, 12, 12, -2], [0, 0, 4, 4], water_color, 'EdgeColor', 'none');
fill([-2, 12, 12, -2], [0, 0, -4, -4], sand_color, 'EdgeColor', 'none');

% 2. Граница
plot([-2, 12], [0, 0], 'k-', 'LineWidth', 3);

% 3. Оптимальная траектория (красная линия)
plot([xA, x_star, xB], [yA, y_boundary, yB], 'r-', 'LineWidth', 3);

% 4. Точки
plot(xA, yA, 'bo', 'MarkerSize', 15, 'LineWidth', 3, 'MarkerFaceColor', 'b');
plot(xB, yB, 'go', 'MarkerSize', 15, 'LineWidth', 3, 'MarkerFaceColor', 'g');
plot(x_star, y_boundary, 'ro', 'MarkerSize', 10, 'LineWidth', 2);

% 5. Подписи
text(xA, yA+0.3, 'Девочка', 'FontSize', 12, 'HorizontalAlignment', 'center');
text(xB, yB-0.3, 'Мальчик', 'FontSize', 12, 'HorizontalAlignment', 'center');
text(x_star, y_boundary-0.3, sprintf('X* = %.3f', x_star), ...
     'FontSize', 11, 'HorizontalAlignment', 'center');
text(5, 2.5, 'ВОДА', 'FontSize', 14, 'HorizontalAlignment', 'center');
text(5, -2.5, 'ПЕСОК', 'FontSize', 14, 'HorizontalAlignment', 'center');

% 6. Рисуем углы
% Угол в воде
angle_radius = 0.8;
% Вспомогательная точка для построения угла
plot([xA, x_star], [yA, yA], 'k:', 'LineWidth', 1); % горизонталь из A
plot([x_star, x_star], [y_boundary, yA], 'k:', 'LineWidth', 1); % вертикаль через X*

% Рисуем дугу для угла α
theta = linspace(-pi/2, -atan2(abs(yA-y_boundary), abs(x_star-xA)), 30);
arc_x = xA + angle_radius * cos(theta);
arc_y = yA + angle_radius * sin(theta);
plot(arc_x, arc_y, 'k-', 'LineWidth', 1.5);
text(xA+0.7, yA-0.3, 'α', 'FontSize', 14, 'FontWeight', 'bold');

% Угол в песке
plot([xB, x_star], [yB, yB], 'k:', 'LineWidth', 1); % горизонталь из B
plot([x_star, x_star], [y_boundary, yB], 'k:', 'LineWidth', 1); % вертикаль через X*

% Рисуем дугу для угла β
theta = linspace(atan2(abs(yB-y_boundary), abs(x_star-xB)), pi/2, 30);
arc_x = xB + angle_radius * cos(theta);
arc_y = yB + angle_radius * sin(theta);
plot(arc_x, arc_y, 'k-', 'LineWidth', 1.5);
text(xB+0.7, yB+0.3, 'β', 'FontSize', 14, 'FontWeight', 'bold');

% Настройки графика
xlabel('x'); ylabel('y');
title(sprintf('Оптимальный путь: T_{min} = %.4f, x* = %.4f', T(x_star), x_star));
xlim([-2, 12]); ylim([-4, 4]);

fprintf('\nГрафик с оптимальной траекторией построен!\n');
fprintf('Красная линия - путь минимального времени.\n');


