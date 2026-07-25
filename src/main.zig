const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    // receiver function
    // the first thing having type as same allows
    // rec1 interects(rec2)
    pub fn interects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const GameConfig = struct {
    screen_width: i32,
    screen_height: i32,
    player_width: f32,
    player_height: f32,
    player_start_y: f32,
    bullet_width: f32,
    bullet_height: f32,
    shield_start_x: f32,
    shield_y: f32,
    shield_width: f32,
    shield_height: f32,
    shield_spacing: f32,
    invader_start_x: f32,
    invader_start_y: f32,
    invader_width: f32,
    invader_height: f32,
    invader_spacing_x: f32,
    invader_spacing_y: f32,
};

// const Example = struct {
//     value: i32,

//     // pub fn init(starting_value: i32) Example {
//     pub fn init(starting_value: i32) @This() {
//         return .{
//             .value = starting_value,
//         };
//     }

//     pub fn update(self: *@This()) void {
//         self.value += 1;
//     }
// };

const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
        };
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position_x += self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position_x -= self.speed;
        }

        if (self.position_x < 0) {
            self.position_x = 0;
        }

        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenHeight())) - self.width;
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.blue,
        );
    }
};

const Bullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 10.0,
            .active = false,
        };
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.position_y -= self.speed;
            if (self.position_y < 0) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.red,
            );
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Invader = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    alive: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .alive = true,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.alive) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.green,
            );
        }
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.position_x += dx;
        self.position_y += dy;
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const EnemyBullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .active = false,
        };
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn update(self: *@This(), screen_height: i32) void {
        if (self.active) {
            self.position_y += self.speed;
            if (self.position_y > @as(f32, @floatFromInt(screen_height))) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.yellow,
            );
        }
    }
};

const Shield = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    health: i32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .health = 10,
        };
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.health > 0) {
            const alpha = @as(u8, @intCast(@min(255, self.health * 25)));
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color{ .r = 0, .g = 255, .b = 255, .a = alpha },
            );
        }
    }
};

fn resetGame(
    player: *Player,
    bullets: []Bullet,
    enemy_bullets: []EnemyBullet,
    shields: []Shield,
    invaders: anytype,
    invader_direction: *f32,
    score: *i32,
    config: GameConfig,
) void {
    score.* = 0;
    player.* = Player.init(
        @as(f32, @floatFromInt(config.screen_width)) / 2 - config.player_width / 2,
        @as(f32, @floatFromInt(config.screen_height)) - 60.0,
        config.player_width,
        config.player_height,
    );
    for (bullets) |*bullet| {
        bullet.active = false;
    }
    for (enemy_bullets) |*bullet| {
        bullet.active = false;
    }
    for (shields, 0..) |*shield, i| {
        const x = config.shield_start_x + @as(f32, @floatFromInt(i)) * config.shield_spacing;
        shield.* = Shield.init(x, config.shield_y, config.shield_width, config.shield_height);
    }
    for (invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = config.invader_start_x + @as(f32, @floatFromInt(j)) * config.invader_spacing_x;
            const y = config.invader_start_y + @as(f32, @floatFromInt(i)) * config.invader_spacing_y;
            invader.* = Invader.init(x, y, config.invader_width, config.invader_height);
        }
    }

    invader_direction.* = 1.0;
}

pub fn main() void {
    const screen_width = 800;
    const screen_height = 600;
    const max_bullets = 10;
    const bullet_width = 4.0;
    const bullet_height = 10.0;

    const invader_rows = 5;
    const invader_cols = 11;
    const invader_width = 40.0;
    const invader_height = 30.0;
    const invader_start_x = 100.0;
    const invader_start_y = 50.0;
    const invader_spacing_x = 60.0;
    const invader_spacing_y = 40.0;
    const invader_speed = 5.0;
    const invader_move_delay = 30;
    const invader_drop_distance = 20.0;
    const max_enemy_bullets = 20;
    const enemy_shoot_delay = 60;
    const enemy_shoot_chance = 5;
    const shield_count = 4;
    const shield_width = 80.0;
    const shield_height = 60.0;
    const shield_start_x = 150.0;
    const shield_y = 450.0;
    const shield_spacing = 150.0;
    const player_width = 50.0;
    const player_height = 30.0;
    const player_start_y = @as(f32, @floatFromInt(screen_height)) - 60.0;
    var game_over: bool = false;
    var game_won: bool = false;
    var invader_direction: f32 = 1.0;
    var move_timer: i32 = 0;
    var enemy_shoot_timer: i32 = 0;
    var score: i32 = 0;

    const config = GameConfig{
        .screen_width = screen_width,
        .screen_height = screen_height,
        .player_start_y = player_start_y,
        .player_width = player_width,
        .player_height = player_height,
        .bullet_width = bullet_width,
        .bullet_height = bullet_height,
        .shield_start_x = shield_start_x,
        .shield_y = shield_y,
        .shield_width = shield_width,
        .shield_height = shield_height,
        .shield_spacing = shield_spacing,
        .invader_start_x = invader_start_x,
        .invader_start_y = invader_start_y,
        .invader_width = invader_width,
        .invader_height = invader_height,
        .invader_spacing_x = invader_spacing_x,
        .invader_spacing_y = invader_spacing_y,
    };

    rl.initWindow(screen_width, screen_height, "Zig");
    defer rl.closeWindow();

    var player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        player_start_y,
        player_width,
        player_height,
    );

    var shields: [shield_count]Shield = undefined;
    for (&shields, 0..) |*shield, i| {
        const x = shield_start_x + @as(f32, @floatFromInt(i)) * shield_spacing;
        shield.* = Shield.init(x, shield_y, shield_width, shield_height);
    }

    var bullets: [max_bullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, bullet_width, bullet_height);
    }

    var enemy_bullets: [max_enemy_bullets]EnemyBullet = undefined;
    for (&enemy_bullets) |*bullet| {
        bullet.* = EnemyBullet.init(0, 0, bullet_width, bullet_height);
    }

    var invaders: [invader_rows][invader_cols]Invader = undefined;
    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = invader_start_x + @as(f32, @floatFromInt(j)) * invader_spacing_x;
            const y = invader_start_y + @as(f32, @floatFromInt(i)) * invader_spacing_y;
            invader.* = Invader.init(x, y, invader_width, invader_height);
        }
    }

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (game_over) {
            rl.drawText("GAME OVER", 270, 250, 40, rl.Color.red);
            const score_text = rl.textFormat("Final Score %d", .{score});
            rl.drawText(score_text, 285, 310, 30, rl.Color.white);
            rl.drawText("Press ENTER to play again or ESC to quit", 180, 360, 20, rl.Color.green);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game_over = false;
                resetGame(
                    &player,
                    &bullets,
                    &enemy_bullets,
                    &shields,
                    &invaders,
                    &invader_direction,
                    &score,
                    config,
                );
            }
            continue;
        }

        if (game_won) {
            rl.drawText("YOU WIN!", 320, 250, 40, rl.Color.gold);
            const score_text = rl.textFormat("Final Score %d", .{score});
            rl.drawText(score_text, 280, 310, 30, rl.Color.white);
            rl.drawText("Press ENTER to play again or ESC to quit", 180, 360, 20, rl.Color.green);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game_won = false;
                resetGame(
                    &player,
                    &bullets,
                    &enemy_bullets,
                    &shields,
                    &invaders,
                    &invader_direction,
                    &score,
                    config,
                );
            }
            continue;
        }

        // UPDATE
        player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = player.position_x + player.width / 2 - bullet.width / 2;
                    bullet.position_y = player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        for (&bullets) |*bullet| {
            if (bullet.active) {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        if (invader.alive) {
                            if (bullet.getRect().interects(invader.getRect())) {
                                bullet.active = false;
                                invader.alive = false;
                                score += 10;
                                break;
                            }
                        }
                    }
                }

                for (&shields) |*shield| {
                    if (shield.health > 0) {
                        if (bullet.getRect().interects(shield.getRect())) {
                            bullet.active = false;
                            shield.health -= 1;
                            break;
                        }
                    }
                }
            }
        }

        for (&enemy_bullets) |*bullet| {
            bullet.update(screen_height);
            if (bullet.active) {
                if (bullet.getRect().interects(player.getRect())) {
                    bullet.active = false;
                    game_over = true;
                }

                for (&shields) |*shield| {
                    if (shield.health > 0) {
                        if (bullet.getRect().interects(shield.getRect())) {
                            bullet.active = false;
                            shield.health -= 1;
                            break;
                        }
                    }
                }
            }
        }

        enemy_shoot_timer += 1;
        if (enemy_shoot_timer >= enemy_shoot_delay) {
            enemy_shoot_timer = 0;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive and rl.getRandomValue(0, 100) < enemy_shoot_chance) {
                        for (&enemy_bullets) |*bullet| {
                            if (!bullet.active) {
                                bullet.position_x = invader.position_x + invader.width / 2 - bullet.width / 2;
                                bullet.position_y = invader.position_y + invader.height;
                                bullet.active = true;
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }

        move_timer += 1;
        if (move_timer >= invader_move_delay) {
            move_timer = 0;

            var hit_edge = false;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        const next_x = invader.position_x + (invader_speed * invader_direction);
                        if (next_x < 0 or next_x + invader.width > @as(f32, @floatFromInt(screen_width))) {
                            hit_edge = true;
                            break;
                        }
                    }
                }
                if (hit_edge) break;
            }

            if (hit_edge) {
                invader_direction *= -1.0;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0, invader_drop_distance);
                    }
                }
            } else {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(invader_speed * invader_direction, 0);
                    }
                }
            }

            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        if (invader.getRect().interects(player.getRect())) {
                            game_over = true;
                        }
                    }
                }
            }
        }

        var all_invaders_dead = true;
        outer_loop: for (&invaders) |*row| {
            for (row) |*invader| {
                if (invader.alive) {
                    all_invaders_dead = false;
                    break :outer_loop;
                }
            }
        }

        if (all_invaders_dead) {
            game_won = true;
        }

        // DRAW LOGIC
        for (&shields) |*shield| {
            shield.draw();
        }

        player.draw();
        for (&bullets) |*bullet| {
            bullet.draw();
        }
        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }

        for (&enemy_bullets) |*bullet| {
            bullet.draw();
        }
        const score_text = rl.textFormat("Score: %d", .{score});
        rl.drawText(score_text, 20, screen_height - 20, 20, rl.Color.white);
        rl.drawText("Zig invaders - press SPACE to shoot, ESC to quit", 20, 20, 20, rl.Color.green);
    }
}
