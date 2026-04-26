function C = create_matrix(alpha, h, a, b)
    n = round((b - a) / h);
    N = n + 1;

    C = zeros(N, N);

    for i = 2:N-1
        C(i, i-1) = -alpha / h^2;
        C(i, i)   = alpha * (1 + 2/h^2);
        C(i, i+1) = -alpha / h^2;
    end

    C(1, 1) = 1;
    C(1, 2) = -1;

    C(N, N-1) = -1;
    C(N, N)   = 1;
end
