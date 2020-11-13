function reverseplot20
% esta funcion crea un Figure con un menu que permite abrir un fichero grafico
% que contenga una grafica para recuperarla. Se debe de seleccionar manualmente:
% - posicion del eje de coordenadas y sus valores
% - posiciones maximas y sus valores de ambos ejes
% - seleccionar los puntos de la grafica uno a uno o seleccionando la linea
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% this function creates a Figure with a menu to open an image file of a graphic and
% recover its information. Some actions must be done:
% - select axis origin and its values
% - select maximum axis position and its values
% - select the individual data points or the line
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Jordi Palacin
% V2.0 - 2011
% http://robotica.udl.cat

himatge = findobj('Tag','reverse');
if (isempty(himatge))

    % crear la nueva figura
    himatge = figure;

    set(himatge,'numbertitle','off');
    set(himatge,'name',mfilename);
    set(himatge,'MenuBar','none');
    set(himatge,'doublebuffer','on');    % dos bufers graficos
    set(himatge,'Tag','reverse');        % identificar figura

    % ######  MENU  ######################################

    Hm_se   = uimenu('Label','&File');
    Hm_load = uimenu(Hm_se,'Label','&Open...','Callback',@loaddata,'Accelerator','o');
    Hm_exit = uimenu(Hm_se,'Label','&Exit','Callback','closereq;','Accelerator','q','separator','on');
    
    Hm_zp   = uimenu('Label','&Image...','enable','off','Tag','FIG');
    Hm_z    = uimenu(Hm_zp,'Label','Activate Zoom','Callback',@toggle,'Tag','ZOOMPAN','Checked','on','Accelerator','Z');
    Hm_z    = uimenu(Hm_zp,'Label','Activate Pan','Callback',@toggle,'Tag','ZOOMPAN','Accelerator','P');
    Hm_z    = uimenu(Hm_zp,'Label','Scale figure (image at 100%)','Callback',@escalar,'Tag','100','separator','on');
    Hm_z    = uimenu(Hm_zp,'Label','Scale figure (image at 50%)','Callback',@escalar,'Tag','50');
    Hm_z    = uimenu(Hm_zp,'Label','Full zoom view','Callback','zoom out;','Tag','ZOOMPAN','Accelerator','F','separator','on');
    if (exist('imrotate.m','file'))
            uimenu(Hm_zp,'Label','Rotate image selecting 2 points of a reference vertical line','Callback',@m_rotarimatge,'Tag','VERT','separator','on');
            uimenu(Hm_zp,'Label','Rotate image selecting 2 points of a reference horitzontal line','Callback',@m_rotarimatge,'Tag','HORZ');
        end
    if (exist('improfile.m','file'))
		Hm_z    = uimenu(Hm_zp,'Label','Make improfile','Callback',@make_improfile,'Tag','IMPROFILE','Accelerator','I','separator','on');
    end
    
    Hm_opt  = uimenu('Label','&Select in figure...','enable','off','Tag','FIG');
    Hm_s1   = uimenu(Hm_opt,'Label','X and Y axis origin','Callback',@dibor,'Tag','STEP1','Accelerator','0');
    Hm_s2   = uimenu(Hm_opt,'Label','X axis maximum (or reference) value','Callback',@dibxmax,'separator','on','enable','off','Tag','STEP2','Accelerator','x');
    Hm_s3   = uimenu(Hm_opt,'Label','X axis scale','enable','off','Tag','STEP2');
    Hm_s31  = uimenu(Hm_s3,'Label','Linear','Callback',@toggle,'Tag','X','checked','on');
    Hm_s32  = uimenu(Hm_s3,'Label','Logarithmic','Callback',@toggle,'Tag','X');
    Hm_s4   = uimenu(Hm_opt,'Label','Y axis maximum (or reference) value','Callback',@dibymax,'separator','on','enable','off','Tag','STEP3','Accelerator','y');
    Hm_s5   = uimenu(Hm_opt,'Label','Y axis scale','enable','off','Tag','STEP3');
    Hm_s51  = uimenu(Hm_s5,'Label','Linear','Callback',@toggle,'Tag','Y','checked','on');
    Hm_s52  = uimenu(Hm_s5,'Label','Logarithmic','Callback',@toggle,'Tag','Y');
    Hm_s6   = uimenu(Hm_opt,'Label','Manual Curve Data points selection (add and remove)','Callback',@mangraf,'separator','on','enable','off','Tag','STEP4','Accelerator','m');
    Hm_s7   = uimenu(Hm_opt,'Label','Automatic Curve Data selection\addition (click over the Curve)...','Callback',@autograf,'enable','off','Tag','STEP4','Accelerator','a');
    Hm_s7   = uimenu(Hm_opt,'Label','Automatic Curve Data selection\addition in a range (click over the Curve)...','Callback',@autograf,'enable','off','Tag','STEP4','Accelerator','r');
    Hm_s8   = uimenu(Hm_opt,'Label','Delete an area of the Data (select area with the mouse)...','Callback',@delarea,'enable','off','Tag','STEP5','Accelerator','d');
    Hm_s8   = uimenu(Hm_opt,'Label','Delete all Data selected...','Callback',@del_all_area,'enable','off','Tag','STEP5');
    Hm_st   = uimenu(Hm_opt,'Label','Data points color in figure...','enable','off','Tag','STEP4');
    Hm_st1  = uimenu(Hm_st,'Label','Magenta','Callback',@toggle,'Tag','color','checked','on');
    Hm_st2  = uimenu(Hm_st,'Label','Blue','Callback',@toggle,'Tag','color');
    Hm_st2  = uimenu(Hm_st,'Label','Cyan','Callback',@toggle,'Tag','color');
    Hm_st2  = uimenu(Hm_st,'Label','Green','Callback',@toggle,'Tag','color');
    
    Hm_d  = uimenu('Label','&Decode','enable','off','Tag','STEP4');
        uimenu(Hm_d,'Label','Select (X, Y) position with the mouse and decode','Callback',@decodificar);
        uimenu(Hm_d,'Label','Select X position with the mouse, decode and interpolate the Y value','Callback',@interpolar,'enable','off','Tag','STEP6');
        if (exist('filtfilt.m','file'))
            uimenu(Hm_d,'Label','Repetitive smooth Data filtering','Callback',@sfilter,'separator','on','enable','off','Tag','STEP6');
        end
    
    Hm_cfs  = uimenu('Label','&Replicate','enable','off','Tag','STEP6');
        uimenu(Hm_cfs,'Label','Create new figure with the Data','Callback',@dibuixar,'Accelerator','n');
        uimenu(Hm_cfs,'Label','Export Data to WorkSpace (in two vectors)','Callback',@exportvar,'Tag','VEC','Accelerator','e','separator','on');
        uimenu(Hm_cfs,'Label','Export Data to WorkSpace (in one matrix)','Callback',@exportvar,'Tag','MAT');
    
    h_opt2 = uimenu('Label','&About ReversePlot');
        uimenu(h_opt2,'Label','Robotic Team, University of Lleida (Spain)');
        uimenu(h_opt2,'Label','GoTo -> http://robotica.udl.cat','Callback','web http://robotica.udl.cat -browser','separator','on');
        
    % enable figure toolbar and leave only zoom and pan buttons
    set(himatge,'toolbar','figure')
    toolbut=allchild(findall(himatge,'Type','uitoolbar'));
    for i=1:length(toolbut)
      if isempty(strfind(get(toolbut(i),'Tag'),'Zoom')) && ...
          isempty(strfind(get(toolbut(i),'Tag'),'Pan'))
          delete(toolbut(i))
      else
          set(toolbut(i),'separator','off')
      end
    end
        
    % initial values
    hvisio.orvalx=0;
    hvisio.orvaly=0;
    hvisio.xmaxval=1;
    hvisio.ymaxval=1;
    
    hvisio.xmaxlabel = '';
    hvisio.xmaxunit  = '';
    hvisio.ymaxlabel = '';
    hvisio.ymaxunit  = '';
    
    hvisio.xvarlabel = 'x';
    hvisio.yvarlabel = 'y';
    hvisio.mvarlabel = 'a';
    
    hvisio.dades_x = [];
    hvisio.dades_y = [];
    
    set(himatge,'userdata',hvisio);
else
    figure(himatge);
end
% ###################################################################################

% ###################################################################################
function loaddata(hco,eventStruct)
% funcion para recuperar los datos

[filename, pathname] = uigetfile( ...
       {'*.jpg;*.jpeg;*.gif;*.png;*.bmp;*.tif','All suported formats'
        '*.jpg;*.jpeg','JPEG (*.jpg;*.jpeg)'; ...
        '*.gif','Gif (*.gif)'; ...
        '*.png','PNG (*.png)'; ...
        '*.bmp','Bitmap (*.bmp)'; ...
        '*.tif','TIFF (*.tif)'}, ...
         'Open scanned image...');

if (ischar(filename))
    himatge = findobj('Tag','reverse');
    hvisio = get(himatge,'userdata');

    % recuperar imagen
    try
        info = imfinfo([pathname filename]);
        [a,map] = imread([pathname filename]);
    catch
        return;
    end
    
    % adecuar el formato
    switch info.ColorType
    case 'grayscale'
        
        % pasar a indexada y a rgb
        [a,map] = gray2ind(a);
        a = ind2rgb(a,map);
        
    case 'indexed'
        
        % pasar a rgb
        a = ind2rgb(a,map);
        
    case 'truecolor'
        
        % ver si es double
        if (isa(a,'uint8')),
            % no lo es
            a = double(a)/255;
        end
            
    end
        
    image(a);
    
    % guardar imagen
    hvisio.image = a;
    
    % reset de seleccion
    hvisio.dades_x = [];
    hvisio.dades_y = [];
    
    set(himatge,'userdata',hvisio);
    
    % nombre del fichero
    set(himatge,'name',[mfilename ': ' filename]);
    
    set(findobj('Tag','FIG'),'enable','on');
    set(findobj('Tag','STEP2'),'enable','off');
    set(findobj('Tag','STEP3'),'enable','off');
    set(findobj('Tag','STEP4'),'enable','off');
    set(findobj('Tag','STEP5'),'enable','off');
    set(findobj('Tag','STEP6'),'enable','off');
    
    zoom reset;
    zoom on;
  
end
% ###################################################################################

% ###################################################################################
function make_improfile(hco, eventStruct)
zoom_pan('off');

improfile;

figure(findobj('Tag','reverse'));
zoom_pan;
% ###################################################################################

% ###################################################################################
function toggle(hco, eventStruct)

% desactivar las opciones
set(findobj('Tag',get(hco,'Tag')),'checked','off');

% activar la opcion
set(hco,'checked','on');

zoom_pan;
data_color;
% ###################################################################################

% ###################################################################################
function zoom_pan(action)

if (nargin > 0)
    pan off;
    zoom off;
    return;
end

if strcmp(get(findobj('Label','Activate Zoom'),'checked'),'on')
    pan off;
    zoom on;
elseif strcmp(get(findobj('Label','Activate Pan'),'checked'),'on')
    zoom off;
    pan on;
end
% ###################################################################################

% ###################################################################################
function escalar(hco, eventStruct)
himatge = findobj('Tag','reverse');
hvisio = get(himatge,'userdata');

% guardar unidades
unidades_axis = get(gca,'Units');
set(gca,'Units','Pixels');
c = get(gca,'Position');
d = get(gcf,'Position');

[n_fil,n_col,n_dim] = size(hvisio.image);

switch get(hco,'Tag')
case {'100'}
    set(gca,'Position',[c(1) c(2) n_col n_fil]);
    inc_col = c(3) - n_col;
    inc_fil = c(4) - n_fil;
    set(gcf,'Position',[d(1) (d(2)+inc_fil) (d(3)-inc_col) (d(4)-inc_fil)]);
case {'50'}
    set(gca,'Position',[c(1) c(2) n_col/2 n_fil/2]);
    inc_col = c(3) - n_col/2;
    inc_fil = c(4) - n_fil/2;
    set(gcf,'Position',[d(1) (d(2)+inc_fil) (d(3)-inc_col) (d(4)-inc_fil)]);
end

% recuperar unidades
set(gca,'Units',unidades_axis);
% ###################################################################################

% ###################################################################################
function c = data_color

% retornar el color
switch get(findobj('Tag','color','Checked','on'),'Label')
case {'Magenta'}
    c = 'm';
case {'Cyan'}
    c = 'c';
case {'Blue'}
    c = 'b';
case {'Green'}
    c = 'g';
end

if (nargin == 0)
    set(findobj('Tag','XYDATA'),'color',c);
end
% ###################################################################################

% ###################################################################################
function dibor(hco, eventStruct)
himatge = findobj('Tag','reverse');
hvisio = get(himatge,'userdata');

delete(findobj('TAG','ORG'));
zoom_pan('off');

refresh;
drawnow;

[x,y]=ginput(1);
if (isempty(x))
    zoom_pan;
    return;
end

hold on;
plot(x,y,'o','TAG','ORG','LineWidth',2);
hold off;
answer=inputdlg({'X axis origin value','Y axis origin value'},'X and Y axis origin',1,{num2str(hvisio.orvalx),num2str(hvisio.orvaly)});
if (isempty(answer))
    % borrar la marca
    delete(findobj('TAG','ORG'));
    zoom_pan;
    return;
end

hvisio.orx=x;
hvisio.ory=y;
hvisio.orvalx=str2num(char(answer(1)));
hvisio.orvaly=str2num(char(answer(2)));
set(himatge,'userdata',hvisio);

set(findobj('Tag','STEP2'),'enable','on');

zoom_pan;
% ###################################################################################

% ###################################################################################
function dibxmax(hco, eventStruct)
himatge = findobj('Tag','reverse');
hvisio = get(himatge,'userdata');

delete(findobj('TAG','XMAX'));
zoom_pan('off');

refresh;
drawnow;

[x,y]=ginput(1);
if (isempty(x))
    zoom_pan;
    return;
end

hold on;
plot(x,y,'o','TAG','XMAX','LineWidth',2);
hold off;
answer=inputdlg({'X axis maximum or reference value','Axis label (optional)','Axis units (optional)'},'X axis',1,{num2str(hvisio.xmaxval),hvisio.xmaxlabel,hvisio.xmaxunit});
if (isempty(answer))
    delete(findobj('TAG','XMAX'));
    zoom_pan;
    return;
end

hvisio.xmaxx=x;
hvisio.xmaxy=y;
hvisio.xmaxval   = str2num(char(answer(1)));
hvisio.xmaxlabel = char(answer(2));
hvisio.xmaxunit  = char(answer(3));
set(himatge,'userdata',hvisio);

set(findobj('Tag','STEP3'),'enable','on');

zoom_pan;
% ###################################################################################

% ###################################################################################
function dibymax(hco, eventStruct)
himatge = findobj('Tag','reverse');
hvisio = get(himatge,'userdata');

delete(findobj('TAG','YMAX'));
zoom_pan('off');

refresh;
drawnow;

[x,y]=ginput(1);
if (isempty(x))
    zoom_pan;
    return;
end

hold on;
plot(x,y,'o','TAG','YMAX','LineWidth',2);
hold off;
answer=inputdlg({'Y axis maximum or reference value','Axis label (optional)','Axis units (optional)'},'Y axis',1,{num2str(hvisio.ymaxval),hvisio.ymaxlabel,hvisio.ymaxunit});
if (isempty(answer))
    delete(findobj('TAG','YMAX'));
    zoom_pan;
    return;
end

hvisio.ymaxx=x;
hvisio.ymaxy=y;
hvisio.ymaxval   = str2num(char(answer(1)));
hvisio.ymaxlabel = char(answer(2));
hvisio.ymaxunit  = char(answer(3));
set(himatge,'userdata',hvisio);

set(findobj('Tag','STEP4'),'enable','on');

zoom_pan;
% ###################################################################################

% ###################################################################################
function mangraf(hco, eventStruct)
himatge = findobj('Tag','reverse');
hvisio = get(himatge,'userdata');

% borrar datos antiguos
zoom_pan('off');

set(findobj('Label','&Image...'),'enable','off');

% add instructions
title('[left click] add new point, [right click] remove nearest point, [enter] to end');

refresh;
drawnow;

xx = hvisio.dades_x;
yy = hvisio.dades_y;

while 1
    
    [x,y,button] = ginput(1);
    if (isempty(x))
        % end of selection
        break;
    end
    
    if (button == 1)
        % add point
        xx = [xx; round(x)];
        yy = [yy; round(y)];
        
    elseif (button == 3)
        % delete selected point
        if (length(xx) > 0)
            d = sqrt((xx-x).^2 + (yy-y).^2);
            i = find(d == min(d));
            xx(i(1)) = [];
            yy(i(1)) = [];
        end
    end
       
    % plot
    [xxx,i] = sort(xx,1,'ascend');
    yyy = yy(i);
    
    % erase old data
    delete(findobj(gcf,'TAG','XYDATA'));
    hold on;
    if (length(xxx) < 100)
        plot(xxx,yyy,[data_color '-*'],'TAG','XYDATA','LineWidth',2);
    else
        plot(xxx,yyy,[data_color '-'],'TAG','XYDATA','LineWidth',2);
    end
    hold off;
end
   
% remove title
title('');
set(findobj('Label','&Image...'),'enable','on');

% store new data
if length(hvisio.dades_x) ~= length(xxx)
    hvisio.dades_x=xxx;
    hvisio.dades_y=yyy;
    set(himatge,'userdata',hvisio);

    set(findobj('Tag','STEP5'),'enable','on');
    set(findobj('Tag','STEP6'),'enable','on');
end

zoom_pan;
% ###################################################################################

% ###################################################################################
function autograf(hco, eventStruct)
himatge = findobj('Tag','reverse');
hvisio = get(himatge,'userdata');

% borrar datos antiguos
delete(findobj('Tag','SEL'));
zoom_pan('off');
set(findobj('Label','&Image...'),'enable','off');

refresh;
drawnow;

title('[Left Click] over the Curve Data');

% pulsar cerca de la linea
[x,y]=ginput(1);
if (isempty(x))
    zoom_pan;
    set(findobj('Label','&Image...'),'enable','on');
    return;
end
x = round(x);
y = round(y);

title('');

xxc = hvisio.dades_x;
yyc = hvisio.dades_y;

% ver si hay que fijar los limites
if strcmp(get(hco,'Label'),'Automatic Curve Data selection\addition in a range (click over the Curve)...')
    
    hold on;
    plot(x,y,'ro','markersize',10,'Tag','SEL');
    hold off;
    
    title('two [Left Click] over the limits of the exploration in the X-axis');
    
    [xlim1,ylim1]=ginput(1);
    if (isempty(xlim1))
        zoom_pan;
        set(findobj('Label','&Image...'),'enable','on');
        return;
    end
    hold on;
    plot(xlim1,ylim1,'sg','markersize',10,'Tag','SEL');
    hold off;
    
    [xlim2,ylim2]=ginput(1);
    if (isempty(xlim2))
        zoom_pan;
        set(findobj('Label','&Image...'),'enable','on');
        return;
    end
    hold on;
    plot(xlim2,ylim2,'sg','markersize',10,'Tag','SEL');
    hold off;
    
    title('');
    
    x_min = min([xlim1 xlim2]);
    x_max = max([xlim1 xlim2]);
    
    % eliminar este rango de los datos iniciales
    i = find((xxc >= x_min) & (xxc <= x_max));
    xxc(i) = [];
    yyc(i) = [];
    
else
    x_min = hvisio.orx;
    x_max = hvisio.xmaxx;
end

% analizar imagen en escala de grises
image = rgb2gray(hvisio.image);

nivel_max = max(max(image));
nivel_min = min(min(image));
nivel_med = mean(mean(image));

% ver si se ha pulsado sobre la linea
if ((nivel_max - nivel_med) < (nivel_med - nivel_min))
    % el color de fondo predominante es claro
    % la linea deberia ser oscura
    color_linea = min(min(image(y-2:y+2,x)));
    
    if (color_linea < nivel_med)
        % linea localizada -> continuar
    else
        % fallo !!!
        zoom_pan;
        set(findobj('Label','&Image...'),'enable','on');
        return;
    end
else
    % el color de fondo predominante es oscuro
    % la linea deberia ser clara
    color_linea = max(max(image(y-5:y+5,x-5:x+5)));
        
    if (color_linea > nivel_med)
        % linea localizada -> continuar
    else
        % fallo !!!
        zoom_pan;
        set(findobj('Label','&Image...'),'enable','on');
        return;
    end
end

% buscar centro de la linea
[xc, yc] = busca_centro(image, x, y, color_linea, 0.3);
x_dades = xc;
y_dades = yc;
        
% a partir del punto seleccionado realizar un barrido hacia derercha e izquierda
yi = yc;
for (x = xc-1:-1:x_min)
    [xi, yi] = busca_centro(image, x, yi, color_linea, 0.3);
            
    if (isempty(yi))
        break;
    end
            
    x_dades = [xi; x_dades];
    y_dades = [yi; y_dades];
end
yi = yc;
for (x = xc+1:+1:x_max)
    [xi, yi] = busca_centro(image, x, yi, color_linea, 0.3);
      
    if (isempty(yi))
        break;
    end
      
    x_dades = [x_dades; xi];
    y_dades = [y_dades; yi];
end

% añadir nuevos datos
xx = [xxc; x_dades];
yy = [yyc; y_dades];

% ordenar
[xxx,i] = sort(xx,1,'ascend');
yyy = yy(i);
    
% eliminar punts repetits
d = diff(xxx);
i = find(d ~= 0);

% recuperar
xx = xxx(i);
yy = yyy(i);

% erase old data
delete(findobj(gcf,'TAG','XYDATA'));
hold on;
plot(xx,yy,[data_color '-'],'TAG','XYDATA','LineWidth',2);
hold off;
   
% store new data
if length(hvisio.dades_x) ~= length(xx)
    hvisio.dades_x=xx;
    hvisio.dades_y=yy;
    set(himatge,'userdata',hvisio);

    set(findobj('Tag','STEP5'),'enable','on');
    set(findobj('Tag','STEP6'),'enable','on');
end

set(findobj('Label','&Image...'),'enable','on');

zoom_pan;
% ###################################################################################

% ###################################################################################
function [xp, yp] = busca_centro(imatge, x, y, color_linea, tolerancia)

% la posicion x es fija, la y es variable
% extraer un trozo de linea y compararlo

p = 1; % search width

s = imatge(y-p:y+p,x) - color_linea;

xp = x;
if (abs(min(s)) > tolerancia)
    yp = [];

else

    % localizar la zona mas parecida al color de linea
    i = find(s == min(s));
    if (length(i) > 1)
        i = round(mean(i));
    end

    % decodificar i
    yp = (y-p) + i -1;
end
% ###################################################################################

% ###################################################################################
function del_all_area(hco, eventStruct)
% eliminar el area seleccionada

% recuperar datos
himatge = findobj('Tag','reverse');
hvisio = get(himatge,'userdata');

% eliminar
hvisio.dades_x = [];
hvisio.dades_y = [];

% guardar
set(himatge,'userdata',hvisio);

% borrar datos antiguos
delete(findobj(gcf,'TAG','XYDATA'));

set(findobj('Tag','STEP5'),'enable','off');
set(findobj('Tag','STEP6'),'enable','off');
% ###################################################################################

% ###################################################################################
function delarea(hco, eventStruct)
% eliminar el area seleccionada

% recuperar datos
himatge = findobj('Tag','reverse');
hvisio = get(himatge,'userdata');

zoom_pan('off');

refresh;
drawnow;

% marcar el area con el mouse
%waitforbuttonpress;
%pos1 = get(gca,'currentpoint');
set(findobj('Label','&Image...'),'enable','off');
pos1 = ginput(1);
if (isempty(pos1))
    set(findobj('Label','&Image...'),'enable','on');
    zoom_pan;
    return;
end

%rbbox([pos1(1) pos1(2) 0 0],get(gcf,'currentpoint'));
rbbox;
pos2 = get(gca,'currentpoint');

set(findobj('Label','&Image...'),'enable','on');

% limites
[y_dim,x_dim,n_col] = size(hvisio.image);

% localizacion en pantalla
i_inicio = min(pos1(1,1),pos2(1,1));
i_final  = max(pos1(1,1),pos2(1,1));

% localizar sobre los datos
i = find((hvisio.dades_x >= i_inicio) & (hvisio.dades_x <= i_final));

% eliminar
hvisio.dades_x(i) = [];
hvisio.dades_y(i) = [];

% guardar
set(himatge,'userdata',hvisio);

% borrar datos antiguos
delete(findobj(gcf,'TAG','XYDATA'));

% mirar si quedan datos
if (isempty(hvisio.dades_x))
    set(findobj('Tag','STEP5'),'enable','off');
    set(findobj('Tag','STEP6'),'enable','off');
end

% redibujar
hold on;
plot(hvisio.dades_x,hvisio.dades_y,[data_color '-'],'TAG','XYDATA','LineWidth',2);
hold off;

zoom_pan;
% ###################################################################################

% ###################################################################################
function dibuixar(hco, eventStruct)
himatge=findobj('Tag','reverse');
hvisio=get(himatge,'userdata');

% detectar ejes
hx = findobj('Tag','X','checked','on');
hy = findobj('Tag','Y','checked','on');

eje_x = get(hx,'Label');
eje_y = get(hy,'Label');

if (length(hvisio.dades_x) > 100)
    str_plot = 'k-';
else
    str_plot = 'ko-';
end

figure;
if (findstr(eje_x,'Lin') & findstr(eje_y,'Lin'))
    
    % normalizar datos lineal
    dades_x = (hvisio.dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (hvisio.xmaxval-hvisio.orvalx) + hvisio.orvalx;

    % normalizar datos lineal
    dades_y = (hvisio.dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (hvisio.ymaxval-hvisio.orvaly) + hvisio.orvaly;
    
    plot(dades_x, dades_y,str_plot);
    
elseif (findstr(eje_x,'Lin') & findstr(eje_y,'Log'))
    
    % normalizar datos lin
    dades_x = (hvisio.dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (hvisio.xmaxval-hvisio.orvalx) + hvisio.orvalx;

    % normalizar datos log
    dades_y = (hvisio.dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (log10(hvisio.ymaxval)-log10(hvisio.orvaly)) + log10(hvisio.orvaly);
    dades_y = 10.^dades_y;
    
    semilogy(dades_x, dades_y,str_plot);
    
elseif (findstr(eje_x,'Log') & findstr(eje_y,'Lin'))
    
    % normalizar datos log
    dades_x = (hvisio.dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (log10(hvisio.xmaxval)-log10(hvisio.orvalx)) + log10(hvisio.orvalx);
    dades_x = 10.^dades_x;

    % normalizar datos log
    dades_y = (hvisio.dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (hvisio.ymaxval-hvisio.orvaly) + hvisio.orvaly;
    
    semilogx(dades_x, dades_y,str_plot);
    
else
    % log log
    
    % normalizar datos log
    dades_x = (hvisio.dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (log10(hvisio.xmaxval)-log10(hvisio.orvalx)) + log10(hvisio.orvalx);
    dades_x = 10.^dades_x;

    % normalizar datos log
    dades_y = (hvisio.dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (log10(hvisio.ymaxval)-log10(hvisio.orvaly)) + log10(hvisio.orvaly);
    dades_y = 10.^dades_y;
    
    loglog(dades_x, dades_y,str_plot);
    
end

% recuperar el axis original
axis([hvisio.orvalx hvisio.xmaxval hvisio.orvaly hvisio.ymaxval]);

% crear els labels
if (~isempty(hvisio.xmaxlabel))
    if (~isempty(hvisio.xmaxunit))
        xlabel([hvisio.xmaxlabel ' (' hvisio.xmaxunit ')']);
    else
        xlabel([hvisio.xmaxlabel]);
    end
end
if (~isempty(hvisio.ymaxlabel))
    if (~isempty(hvisio.ymaxunit))
        ylabel([hvisio.ymaxlabel ' (' hvisio.ymaxunit ')']);
    else
        ylabel([hvisio.ymaxlabel]);
    end
end
% ###################################################################################

% ###################################################################################
function exportvar(hco, eventStruct)
% exportar variable a workspace

% recuperar y acondicionar los datos
himatge=findobj('Tag','reverse');
hvisio=get(himatge,'userdata');

% detectar ejes
hx = findobj('Tag','X','checked','on');
hy = findobj('Tag','Y','checked','on');

eje_x = get(hx,'Label');
eje_y = get(hy,'Label');

if (findstr(eje_x,'Lin') & findstr(eje_y,'Lin'))
    
    % normalizar datos lineal
    dades_x = (hvisio.dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (hvisio.xmaxval-hvisio.orvalx) + hvisio.orvalx;

    % normalizar datos lineal
    dades_y = (hvisio.dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (hvisio.ymaxval-hvisio.orvaly) + hvisio.orvaly;
       
elseif (findstr(eje_x,'Lin') & findstr(eje_y,'Log'))
    
    % normalizar datos lin
    dades_x = (hvisio.dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (hvisio.xmaxval-hvisio.orvalx) + hvisio.orvalx;

    % normalizar datos log
    dades_y = (hvisio.dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (log10(hvisio.ymaxval)-log10(hvisio.orvaly)) + log10(hvisio.orvaly);
    dades_y = 10.^dades_y;
    
elseif (findstr(eje_x,'Log') & findstr(eje_y,'Lin'))
    
    % normalizar datos log
    dades_x = (hvisio.dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (log10(hvisio.xmaxval)-log10(hvisio.orvalx)) + log10(hvisio.orvalx);
    dades_x = 10.^dades_x;

    % normalizar datos log
    dades_y = (hvisio.dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (hvisio.ymaxval-hvisio.orvaly) + hvisio.orvaly;
    
else
    % log log
    
    % normalizar datos log
    dades_x = (hvisio.dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (log10(hvisio.xmaxval)-log10(hvisio.orvalx)) + log10(hvisio.orvalx);
    dades_x = 10.^dades_x;

    % normalizar datos log
    dades_y = (hvisio.dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (log10(hvisio.ymaxval)-log10(hvisio.orvaly)) + log10(hvisio.orvaly);
    dades_y = 10.^dades_y;
       
end

switch get(hco,'Tag')
case {'VEC'}

    % exportar a MATLAB
    answer=inputdlg({'Variable name for axis X data...','Variable name for axis Y data...'},'Export data',1,{hvisio.xvarlabel,hvisio.yvarlabel});
    if (isempty(answer))
        return;
    end
    hvisio.xvarlabel = char(answer(1));
    hvisio.yvarlabel = char(answer(2));
    set(himatge,'userdata',hvisio);

    var_x = char(answer(1));
    var_y = char(answer(2));

    try
        % pasar a WorkSpace
        evalin('base','global xyzw_temp;');
        global xyzw_temp;
        
        % mirar si existeix la variable
        evalin('base',['xyzw_temp = exist(''' var_x ''',''var'');']);
        
        if xyzw_temp
            button = questdlg(['Variable name ''' var_x ''' already exist in WorkSpace.'],'Attention','Continue & replace','Cancel','Cancel');
            switch button
            case 'Cancel'
                evalin('base','clear xyzw_temp;');
                clear xyzw_temp;
                return;
            end
        end
        
        % mirar si existeix la variable
        evalin('base',['xyzw_temp = exist(''' var_y ''',''var'');']);
        
        if xyzw_temp
            button = questdlg(['Variable name ''' var_y ''' already exist in WorkSpace.'],'Attention','Continue & replace','Cancel','Cancel');
            switch button
            case 'Cancel'
                evalin('base','clear xyzw_temp;');
                clear xyzw_temp;
                return;
            end
        end

        % datos X
        xyzw_temp = dades_x';
        evalin('base',[var_x ' = xyzw_temp;']);

        % datos Y
        xyzw_temp = dades_y';
        evalin('base',[var_y ' = xyzw_temp;']);

        evalin('base','clear xyzw_temp;');
        clear xyzw_temp;
    catch
        evalin('base','clear xyzw_temp;');
        clear xyzw_temp;
        uiwait(errordlg('Error in the export process...','ERROR','modal'));
    end
    
otherwise
    
    % exportar a MATLAB
    answer=inputdlg({'Variable name = [y; x]'},'Export data',1,{hvisio.mvarlabel});
    if (isempty(answer))
        return;
    end
    hvisio.mvarlabel = char(answer(1));
    set(himatge,'userdata',hvisio);

    var_m = char(answer(1));

    try
        % pasar a WorkSpace
        evalin('base','global xyzw_temp;');
        global xyzw_temp;
        
        % mirar si existeix la variable
        evalin('base',['xyzw_temp = exist(''' var_m ''',''var'');']);
        
        if xyzw_temp
            button = questdlg(['Variable name ''' var_m ''' already exist in WorkSpace.'],'Attention','Continue & replace','Cancel','Cancel');
            switch button
            case 'Cancel'
                evalin('base','clear xyzw_temp;');
                clear xyzw_temp;
                return;
            end
        end

        % datos Y
        xyzw_temp = dades_y';
        evalin('base',[var_m ' = [];']);
        evalin('base',[var_m '(1,:) = xyzw_temp;']);
        
        % datos X
        xyzw_temp = dades_x';
        evalin('base',[var_m '(2,:) = xyzw_temp;']);

        evalin('base','clear xyzw_temp;');
        clear xyzw_temp;
    catch
        evalin('base','clear xyzw_temp;');
        clear xyzw_temp;
        uiwait(errordlg('Error in the export process...','ERROR','modal'));
    end
end
% ###################################################################################

% ###################################################################################
function decodificar(hco, eventStruct)
% decodificar

% recuperar y acondicionar los datos
himatge=findobj('Tag','reverse');
hvisio=get(himatge,'userdata');

zoom_pan('off');

refresh;
drawnow;

% efectuar la seleccion del punto
[dades_x,dades_y] = ginput(1);
if (isempty(dades_x))
    return;
end

delete(findobj('TAG','POINT'));
hold on;
plot(dades_x,dades_y,'g+','TAG','POINT','MarkerSize',12);
hold off;

% detectar ejes
hx = findobj('Tag','X','checked','on');
hy = findobj('Tag','Y','checked','on');

eje_x = get(hx,'Label');
eje_y = get(hy,'Label');

if (findstr(eje_x,'Lin') & findstr(eje_y,'Lin'))
    
    % normalizar datos lineal
    dades_x = (dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (hvisio.xmaxval-hvisio.orvalx) + hvisio.orvalx;

    % normalizar datos lineal
    dades_y = (dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (hvisio.ymaxval-hvisio.orvaly) + hvisio.orvaly;
       
elseif (findstr(eje_x,'Lin') & findstr(eje_y,'Log'))
    
    % normalizar datos lin
    dades_x = (dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (hvisio.xmaxval-hvisio.orvalx) + hvisio.orvalx;

    % normalizar datos log
    dades_y = (dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (log10(hvisio.ymaxval)-log10(hvisio.orvaly)) + log10(hvisio.orvaly);
    dades_y = 10.^dades_y;
    
elseif (findstr(eje_x,'Log') & findstr(eje_y,'Lin'))
    
    % normalizar datos log
    dades_x = (dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (log10(hvisio.xmaxval)-log10(hvisio.orvalx)) + log10(hvisio.orvalx);
    dades_x = 10.^dades_x;

    % normalizar datos log
    dades_y = (dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (hvisio.ymaxval-hvisio.orvaly) + hvisio.orvaly;
    
else
    % log log
    
    % normalizar datos log
    dades_x = (dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (log10(hvisio.xmaxval)-log10(hvisio.orvalx)) + log10(hvisio.orvalx);
    dades_x = 10.^dades_x;

    % normalizar datos log
    dades_y = (dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (log10(hvisio.ymaxval)-log10(hvisio.orvaly)) + log10(hvisio.orvaly);
    dades_y = 10.^dades_y;
       
end

% mostrar en pantalla
% crear els labels
if (~isempty(hvisio.xmaxlabel))
    x_label = hvisio.xmaxlabel;
else
    x_label = 'X axis value...';
end
if (~isempty(hvisio.ymaxlabel))
    y_label = hvisio.ymaxlabel;
else
    y_label = 'Y axis value...';
end

answer=inputdlg({x_label,y_label},'Decoded',1,{[num2str(dades_x) ' ' hvisio.xmaxunit],[num2str(dades_y) ' ' hvisio.ymaxunit]});

zoom_pan;
% ###################################################################################

% ###################################################################################
function sfilter(hco, eventStruct)
% filtrar

% recuperar y acondicionar los datos
himatge=findobj('Tag','reverse');
hvisio=get(himatge,'userdata');

% filtering
hvisio.dades_y = filtfilt((1/5)*[1 1 1 1 1],1, hvisio.dades_y);

% guardar
set(himatge,'userdata',hvisio);

% borrar datos antiguos
delete(findobj(gcf,'TAG','XYDATA'));

hold on;
plot(hvisio.dades_x,hvisio.dades_y,[data_color '-'],'TAG','XYDATA','LineWidth',2);
hold off;

zoom_pan;
% ###################################################################################

% ###################################################################################
function interpolar(hco, eventStruct)
% exportar variable a workspace

% recuperar y acondicionar los datos
himatge=findobj('Tag','reverse');
hvisio=get(himatge,'userdata');

zoom_pan('off');

refresh;
drawnow;

% efectuar la seleccion del punto
[dades_x,dades_yy] = ginput(1);
if (isempty(dades_x))
    zoom_pan;
    return;
end

% interpolar con los datos disponibles
% eliminar puntos X repetidos
i = diff(hvisio.dades_x);
ii = find(i == 0);
if (~isempty(ii))
    hvisio.dades_x(ii) = [];
    hvisio.dades_y(ii) = [];
end
dades_y = interp1(hvisio.dades_x', hvisio.dades_y', dades_x,'linear','extrap');

delete(findobj('TAG','POINT'));
hold on;
plot(dades_x*[1 1],[dades_y dades_yy],'c:','TAG','POINT');
plot(dades_x,dades_y,'c+','TAG','POINT','MarkerSize',12);
hold off;

% detectar ejes
hx = findobj('Tag','X','checked','on');
hy = findobj('Tag','Y','checked','on');

eje_x = get(hx,'Label');
eje_y = get(hy,'Label');

if (findstr(eje_x,'Lin') & findstr(eje_y,'Lin'))
    
    % normalizar datos lineal
    dades_x = (dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (hvisio.xmaxval-hvisio.orvalx) + hvisio.orvalx;

    % normalizar datos lineal
    dades_y = (dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (hvisio.ymaxval-hvisio.orvaly) + hvisio.orvaly;
       
elseif (findstr(eje_x,'Lin') & findstr(eje_y,'Log'))
    
    % normalizar datos lin
    dades_x = (dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (hvisio.xmaxval-hvisio.orvalx) + hvisio.orvalx;

    % normalizar datos log
    dades_y = (dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (log10(hvisio.ymaxval)-log10(hvisio.orvaly)) + log10(hvisio.orvaly);
    dades_y = 10.^dades_y;
    
elseif (findstr(eje_x,'Log') & findstr(eje_y,'Lin'))
    
    % normalizar datos log
    dades_x = (dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (log10(hvisio.xmaxval)-log10(hvisio.orvalx)) + log10(hvisio.orvalx);
    dades_x = 10.^dades_x;

    % normalizar datos log
    dades_y = (dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (hvisio.ymaxval-hvisio.orvaly) + hvisio.orvaly;
    
else
    % log log
    
    % normalizar datos log
    dades_x = (dades_x-hvisio.orx)/(hvisio.xmaxx-hvisio.orx);
    % escalar
    dades_x = dades_x * (log10(hvisio.xmaxval)-log10(hvisio.orvalx)) + log10(hvisio.orvalx);
    dades_x = 10.^dades_x;

    % normalizar datos log
    dades_y = (dades_y-hvisio.ory)/(hvisio.ymaxy-hvisio.ory);
    % escalar
    dades_y = dades_y * (log10(hvisio.ymaxval)-log10(hvisio.orvaly)) + log10(hvisio.orvaly);
    dades_y = 10.^dades_y;
       
end

% mostrar en pantalla
% crear els labels
if (~isempty(hvisio.xmaxlabel))
    x_label = hvisio.xmaxlabel;
else
    x_label = 'X axis value...';
end
if (~isempty(hvisio.ymaxlabel))
    y_label = ['Interpolated ' hvisio.ymaxlabel];
else
    y_label = 'Interpolated Y axis value...';
end

answer=inputdlg({x_label,y_label},'Decoded values from figure',1,{[num2str(dades_x) ' ' hvisio.xmaxunit],[num2str(dades_y) ' ' hvisio.ymaxunit]});

zoom_pan;
% ###################################################################################

% #########################################################################
function m_rotarimatge(hco,eventStruct)
himatge=findobj('Tag','reverse');
hvisio=get(himatge,'userdata');

zoom_pan('off');

refresh;
drawnow;

% veure que hem de fer
switch get(hco,'Tag')
case {'HORZ'}
    
    % linea horitzontal
    % marcar els dos punts
    [c1,f1] = ginput(1);
    if (isempty(c1))
        zoom_pan;
        return;
    end
    
    hold on;
    plot(c1,f1,'y+','Tag','PLOTANTERIOR');
    
    [c2,f2] = ginput(1);
    if (isempty(c2))
        zoom_pan;
        return;
    end
    
    plot(c2,f2,'y+','Tag','PLOTANTERIOR');
    hold off;
    refresh;
    drawnow;
    
    % ordenar, sempre f1 a baix
    if (c1 > c2)
        a = f1;
        f1 = f2;
        f2 = a;
        a = c1;
        c1 = c2;
        c2 = a;
    end
   
    % determinar l'angle horitzontal
    angle = 180*atan2(f2-f1,c2-c1)/pi;
    
case {'VERT'}
    
    % linea vertical
    % marcar els dos punts
    [c1,f1] = ginput(1);
    if (isempty(c1))
        zoom_pan;
        return;
    end
    
    hold on;
    plot(c1,f1,'y+','Tag','PLOTANTERIOR');
    
    [c2,f2] = ginput(1);
    if (isempty(c2))
        zoom_pan;
        return;
    end
    
    plot(c2,f2,'y+','Tag','PLOTANTERIOR');
    hold off;
    refresh;
    drawnow;
    
    % ordenar, sempre f1 a baix
    if (f2 > f1)
        a = f1;
        f1 = f2;
        f2 = a;
        a = c1;
        c1 = c2;
        c2 = a;
    end
   
    % determinar l'angle horitzontal
    angle = 90 +180*atan2(f2-f1,c2-c1)/pi;    
end

if (angle == 0)
    zoom_pan;
    return;
else
    set(himatge,'pointer','watch');
    
    refresh;
    drawnow;
    
    imout = imrotate(hvisio.image,angle,'bilinear','crop');
    % limites
    i = find(imout > 1);
    imout(i) = 1;
    i = find(imout < 0);
    imout(i) = 0;
    
    % guardar imagen
    hvisio.image=imout;
    
    image(imout);
    
    set(himatge,'pointer','arrow');
    
    % reset de seleccion
    hvisio.dades_x = [];
    hvisio.dades_y = [];
    
    set(himatge,'userdata',hvisio);
    
    set(findobj('Tag','FIG'),'enable','on');
    set(findobj('Tag','STEP2'),'enable','off');
    set(findobj('Tag','STEP3'),'enable','off');
    set(findobj('Tag','STEP4'),'enable','off');
    set(findobj('Tag','STEP5'),'enable','off');
    set(findobj('Tag','STEP6'),'enable','off');
    
    zoom reset;
    zoom on;
end
% #########################################################################