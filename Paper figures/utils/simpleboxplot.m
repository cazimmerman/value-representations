function simpleboxplot(x,y,c)

hold on
yprime = prctile(y,[10 25 50 75 90]);
plot([x x],[yprime(4) yprime(5)],'color',c,'linewidth',1)
plot([x x],[yprime(1) yprime(2)],'color',c,'linewidth',1)
fill(x+[-.25 +.25 +.25 -.25 -.25],[yprime(2) yprime(2) yprime(4) yprime(4) yprime(2)],c,'edgecolor',c,'FaceColor',c,'linewidth',1,'facealpha',0.15)
plot(x+[-.25 +.25],[yprime(3) yprime(3)],'color',c,'linewidth',1)