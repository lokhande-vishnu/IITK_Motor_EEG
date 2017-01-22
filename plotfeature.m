function plotfeature(pre_rxy2)
for i = 2:236
    x_plot = 1:size(pre_rxy2,1);   
    h = figure;  
    
    a=pre_rxy2(:,i);    
    plot(x_plot, a );
    %set(gca,'XTick',0:datawidth/4:dataset*datawidth);
    grid on;     
    
    path = sprintf('D:\\brain\\output\\sample %d',i);
    %legend({'Healthy','Faulty'}, 'Location', 'NorthEast');
    ti = sprintf('sample %d',i);
    title(ti);
    xlabel('lag(m)');ylabel('Amplitude');
    saveas(h,path,'png'); 
    close;
        
   
end
end
