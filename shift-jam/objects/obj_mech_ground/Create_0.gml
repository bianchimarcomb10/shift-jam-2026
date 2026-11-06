/// Il mecha a terra: si muove e falcia; poi gli alieni lo bloccano.
sweep_cooldown = 0;
sweep_anim = 0;
sweep_radius = 56;
transformed = false;   // diventa true quando si preme SHIFT
unfold = 0;            // da 0 a 1: il mecha si riapre in navicella dopo SHIFT
mech_speed = 2.5;      // come il mecha nello spazio
vy = 0;                // velocita' verticale durante il decollo
bottom_y = room_height - 40;   // dove finisce schiacciato quando gli alieni lo sommergono
