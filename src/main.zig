const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

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
};

pub fn main() void {
    const screen_width = 800;
    const screen_height = 600;
    const max_bullets = 10;
    const bullet_width = 4.0;
    const bullet_height = 10.0;

    rl.initWindow(screen_width, screen_height, "Zig");
    defer rl.closeWindow();

    const player_width = 50.0;
    const player_height = 30.0;

    var player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        @as(f32, @floatFromInt(screen_height)) - 60.0,
        player_width,
        player_height,
    );

    var bullets: [max_bullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, bullet_width, bullet_height);
    }

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                bullet.position_x = player.position_x + player.width / 2 - bullet.width / 2;
                bullet.position_y = player.position_y;
                bullet.active = true;
                break;
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        player.draw();
        for (&bullets) |*bullet| {
            bullet.draw();
        }
    }

    return;
}
