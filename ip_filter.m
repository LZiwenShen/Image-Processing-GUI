function image_out = ip_filter(image_in, filter ,type)
[m, n] = size(image_in);
[mf, nf] = size(filter);
c = (mf - 1) / 2;
image2 = zeros(m+2*c, n+2*c, 'double');
image_out = zeros(m, n, 'uint8');
coeff = sum(filter(:));
%%
for i = 1+c : m+c
    for j = 1+c : n+c
        image2(i, j) = image_in(i-c, j-c);
    end
end
for i = 1 : c
    for j = 1 : n
        image2(i, j+c) = image_in(1, j);
        image2(m+c+i, j+c) = image_in(m, j);
    end
end
for i = 1 : m
    for j = 1 : c
        image2(i+c, j) = image_in(i, 1);
        image2(i+c, n+c+j) = image_in(i, n);
    end
end
for i = 1 : c
    for j = 1 : c
        image2(i, j) = image_in(1, 1); 
        image2(i, j+n+c) = image_in(1, n); 
        image2(i+n+c, j) = image_in(m, 1); 
        image2(i+n+c, j+n+c) = image_in(m, n); 
    end
end
%%
if strcmp(type,'average') || strcmp(type,'gaussian')
    for i = 1+c : m+c
        for j = 1+c : n+c
            sub_image = image2(i-c:i+c, j-c:j+c);
            temp1 = double(filter') .* double(sub_image);
            temp2 = sum(temp1(:)) / coeff;
            image_out(i-c, j-c) = uint8(temp2);
        end
    end
elseif strcmp(type,'cross')
    for i = 1+c : m+c
        for j = 1+c : n+c
            sub_image = image2(i-c:i+c, j-c:j+c);
            temp = median(sub_image(:));
            image_out(i-c, j-c) = uint8(temp);
        end
    end
elseif strcmp(type,'Roberts')
    for i = 1+c : m+c
        for j = 1+c : n+c
            temp = abs(image2(i,j)-image2(i+1,j+1))+abs(image2(i,j+1)-image2(i+1,j));
            image_out(i-c, j-c) = uint8(image2(i,j)-temp);
        end
    end
elseif strcmp(type,'Laplacian')
    for i = 1+c : m+c
        for j = 1+c : n+c
            sub_image = image2(i-c:i+c, j-c:j+c);
            temp = sum(double(filter') .* double(sub_image),"all");
            image_out(i-c, j-c) = uint8(image2(i,j)-temp);
        end
    end
elseif strcmp(type,'Prewitt')
    temp1_kernel = [1,1,1;0,0,0;-1,-1,-1];
    temp3_kernel = [-1,0,1;-1,0,1;-1,0,1];
    for i = 1+c : m+c
        for j = 1+c : n+c
            sub_image = image2(i-c:i+c, j-c:j+c);
            temp1 = sum(temp1_kernel .* double(sub_image),"all");
            temp3 = sum(temp3_kernel .* double(sub_image),"all");
            temp_array = [temp1,temp3];
            temp = max(temp_array);
            image_out(i-c, j-c) = uint8(image2(i,j)-temp);
        end
    end
elseif strcmp(type,'canny')%输入就已经是经过平滑的图像了
    sobel_x = [1,2,1;0,0,0;-1,-2,-1];
    sobel_y = [-1,0,1;-2,0,2;-1,0,1];
    M = zeros(m+2*c,n+2*c);
    theta = zeros(m+2*c,n+2*c);
    %梯度幅值及方向
    for i = 1+c : m+c
        for j = 1+c : n+c
            sub_image = image2(i-c:i+c, j-c:j+c);
            x = sum(sobel_x .* double(sub_image),"all");
            y = sum(sobel_y .* double(sub_image),"all");
            M(i, j) = abs(x) + abs(y);
            theta(i, j) = atan(y/x);
        end
    end
    %非极大值抑制
    for i = 1+c : m+c
        for j = 1+c : n+c
            if theta(i,j)>22.5 && theta(i,j)<67.5
                if M(i,j)>M(i+1,j-1) && M(i,j)>M(i-1,j+1)
                    image_out(i-c,j-c) = M(i,j);
                else
                    image_out(i-c,j-c) = 0;
                end
            elseif theta(i,j)<22.5 && theta(i,j)>-22.5
                if M(i,j)>M(i+1,j) && M(i,j)>M(i-1,j)
                    image_out(i-c,j-c) = M(i,j);
                else
                    image_out(i-c,j-c) = 0;
                end
            elseif theta(i,j)<-22.5 && theta(i,j)>-67.5
                if M(i,j)>M(i+1,j+1) && M(i,j)>M(i-1,j-1)
                    image_out(i-c,j-c) = M(i,j);
                else
                    image_out(i-c,j-c) = 0;
                end
            else
                if M(i,j)>M(i,j+1) && M(i,j)>M(i,j-1)
                    image_out(i-c,j-c) = M(i,j);
                else
                    image_out(i-c,j-c) = 0;
                end
            end
        end
    end
    [low,index] = max(max(M));
    low = 0.025*low;
    high = 2*low;
    for i = 2 : m-1
        for j = 2 : n-1
            if image_out(i,j)<low
                image_out(i,j) = 0;
            elseif image_out(i,j)<high
                temp_array=[image_out(i-1,j-1),image_out(i-1,j),image_out(i-1,j+1),image_out(i,j-1),image_out(i,j+1),image_out(i+1,j-1),image_out(i+1,j),image_out(i+1,j+1)];
                [temp,index]=max(temp_array);
                if temp<high
                    image_out(i,j)=0;
                end
            end
        end
    end
end



