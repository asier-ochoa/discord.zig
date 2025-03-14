//! ISC License
//!
//! Copyright (c) 2024-2025 Yuzu
//!
//! Permission to use, copy, modify, and/or distribute this software for any
//! purpose with or without fee is hereby granted, provided that the above
//! copyright notice and this permission notice appear in all copies.
//!
//! THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//! REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
//! AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
//! INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
//! LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
//! OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
//! PERFORMANCE OF THIS SOFTWARE.

const ApplicationCommandTypes = @import("shared.zig").ApplicationCommandTypes;
const Locales = @import("shared.zig").Locales;
const InteractionContextType = @import("integration.zig").InteractionContextType;
const Snowflake = @import("snowflake.zig").Snowflake;
const ApplicationCommandPermissionTypes = @import("shared.zig").ApplicationCommandPermissionTypes;
const ApplicationIntegrationType = @import("application.zig").ApplicationIntegrationType;
const ApplicationCommandOptionTypes = @import("shared.zig").ApplicationCommandOptionTypes;
const ChannelTypes = @import("shared.zig").ChannelTypes;
const JsonType = @import("../json.zig").JsonType;
const parseInto = @import("../json.zig").parseInto;
const std = @import("std");

/// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-structure
pub const ApplicationCommand = struct {
    /// Type of command, defaults to `ApplicationCommandTypes.ChatInput`
    type: ?ApplicationCommandTypes,
    ///
    /// Name of command, 1-32 characters.
    /// `ApplicationCommandTypes.ChatInput` command names must match the following regex `^[-_\p{L};\p{N};\p{sc=Deva};\p{sc=Thai};]{1,32};$` with the unicode flag set.
    /// If there is a lowercase variant of any letters used, you must use those.
    /// Characters with no lowercase variants and/or uncased letters are still allowed.
    /// ApplicationCommandTypes.User` and `ApplicationCommandTypes.Message` commands may be mixed case and can include spaces.
    ///
    name: []const u8,
    /// Localization object for `name` field. Values follow the same restrictions as `name`
    name_localizations: ?LocaleMap, //?Localization,
    /// Description for `ApplicationCommandTypes.ChatInput` commands, 1-100 characters.
    /// DISCORD API DOCS ARE WRONG, THIS FIELD MUST BE PRESENT
    description: []const u8,
    /// Localization object for `description` field. Values follow the same restrictions as `description`
    description_localizations: ?LocaleMap, //?Localization,
    /// Parameters for the command, max of 25
    options: ?[]ApplicationCommandOption,
    /// Set of permissions represented as a bit set
    default_member_permissions: ?[]const u8,
    ///
    /// Installation contexts where the command is available
    ///
    /// @remarks
    /// This value is available only for globally-scoped commands
    /// Defaults to the application configured contexts
    ///
    integration_types: ?[]ApplicationIntegrationType,
    ///
    /// Interaction context(s) where the command can be used
    ///
    /// @remarks
    /// This value is available only for globally-scoped commands
    /// By default, all interaction context types included for new commands.
    ///
    contexts: ?[]InteractionContextType,
    ///
    /// Indicates whether the command is available in DMs with the app, only for globally-scoped commands. By default, commands are visible.
    ///
    /// @deprecated use {@link contexts}; instead
    ///
    dm_permission: ?bool,
    /// Indicates whether the command is age-restricted, defaults to false
    nsfw: ?bool,
    /// Auto incrementing version identifier updated during substantial record changes
    version: ?[]const u8,
    ///
    ///Determines whether the interaction is handled by the app's interactions handler or by
    ///
    /// @remarks
    /// This can only be set for application commands of type `PRIMARY_ENTRY_POINT` for applications with the `EMBEDDED` flag (i.e. applications that have an Activity).
    ///
    handler: ?InteractionEntryPointCommandHandlerType,
    /// Unique ID of command
    id: Snowflake,
    /// ID of the parent application
    application_id: Snowflake,
    /// Guild id of the command, if not global
    guild_id: ?Snowflake,
};

pub const CreateApplicationCommand = struct {
    /// Type of command, defaults to `ApplicationCommandTypes.ChatInput`
    type: ?ApplicationCommandTypes,
    ///
    /// Name of command, 1-32 characters.
    /// `ApplicationCommandTypes.ChatInput` command names must match the following regex `^[-_\p{L};\p{N};\p{sc=Deva};\p{sc=Thai};]{1,32};$` with the unicode flag set.
    /// If there is a lowercase variant of any letters used, you must use those.
    /// Characters with no lowercase variants and/or uncased letters are still allowed.
    /// ApplicationCommandTypes.User` and `ApplicationCommandTypes.Message` commands may be mixed case and can include spaces.
    ///
    name: []const u8,
    /// Localization object for `name` field. Values follow the same restrictions as `name`
    name_localizations: ?LocaleMap, //?Localization,
    /// Description for `ApplicationCommandTypes.ChatInput` commands, 1-100 characters.
    /// DISCORD API DOCS ARE WRONG, THIS FIELD MUST BE PRESENT
    description: []const u8,
    /// Localization object for `description` field. Values follow the same restrictions as `description`
    description_localizations: ?LocaleMap, //?Localization,
    /// Parameters for the command, max of 25
    options: ?[]const ApplicationCommandOption,
    /// Set of permissions represented as a bit set
    default_member_permissions: ?[]const u8,
    ///
    /// Installation contexts where the command is available
    ///
    /// @remarks
    /// This value is available only for globally-scoped commands
    /// Defaults to the application configured contexts
    ///
    integration_types: ?[]ApplicationIntegrationType,
    ///
    /// Interaction context(s) where the command can be used
    ///
    /// @remarks
    /// This value is available only for globally-scoped commands
    /// By default, all interaction context types included for new commands.
    ///
    contexts: ?[]InteractionContextType,
    ///
    /// Indicates whether the command is available in DMs with the app, only for globally-scoped commands. By default, commands are visible.
    ///
    /// @deprecated use {@link contexts}; instead
    ///
    dm_permission: ?bool,
    /// Indicates whether the command is age-restricted, defaults to false
    nsfw: ?bool,
    /// Auto incrementing version identifier updated during substantial record changes
    version: ?[]const u8,
    ///
    ///Determines whether the interaction is handled by the app's interactions handler or by
    ///
    /// @remarks
    /// This can only be set for application commands of type `PRIMARY_ENTRY_POINT` for applications with the `EMBEDDED` flag (i.e. applications that have an Activity).
    ///
    handler: ?InteractionEntryPointCommandHandlerType,
};

pub const LocaleMap = struct {
    map: std.EnumMap(Locales, []const u8),

    pub fn init(init_values: std.enums.EnumFieldStruct(Locales, ?[]const u8, @as(?[]const u8, null))) @This() {
        return .{ .map = .init(init_values) };
    }

    pub fn jsonStringify(self: *const @This(), jw: anytype) !void {
        const map = &self.map;

        // Write all fields of the map as a JSON object
        try jw.beginObject();
        inline for (std.meta.fields(Locales)) |k| {
            const key_tag = std.meta.stringToEnum(Locales, k.name).?;
            if (map.contains(key_tag)) {
                try jw.objectField(k.name);
                try jw.write(map.getAssertContains(key_tag));
            }
        }
        try jw.endObject();
    }

    /// Internal parsing function for zjson
    pub fn json(allocator: std.mem.Allocator, value: JsonType) !@This() {
        var map: std.EnumMap(Locales, []const u8) = .{};

        var iterator = value.object.iterator();

        while (iterator.next()) |pair| {
            const k = pair.key_ptr.*;
            const v = pair.value_ptr.*;

            defer allocator.free(k);
            errdefer v.deinit(allocator);

            // TODO: handle when a string received is invalid
            map.put(std.meta.stringToEnum(Locales, k).?, try parseInto([]const u8, allocator, v));
        }
        return .{ .map = map };
    }
};

pub const InteractionEntryPointCommandHandlerType = enum(u4) {
    /// The app handles the interaction using an interaction token
    AppHandler = 1,
    /// handles the interaction by launching an Activity and sending a follow-up message without coordinating with the app
    LaunchActivity = 2,
};

/// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-structure
pub const ApplicationCommandOption = struct {
    /// Type of option
    type: ApplicationCommandOptionTypes,
    ///
    /// Name of command, 1-32 characters.
    ///
    /// @remarks
    ///This value should be unique within an array of {@link ApplicationCommandOption};
    ///
    /// {@link ApplicationCommandTypes.ChatInput | ChatInput}; command names must match the following regex `^[-_\p{L};\p{N};\p{sc=Deva};\p{sc=Thai};]{1,32};$` with the unicode flag set.
    /// If there is a lowercase variant of any letters used, you must use those.
    /// Characters with no lowercase variants and/or uncased letters are still allowed.
    ///
    /// {@link ApplicationCommandTypes.User | User}; and {@link ApplicationCommandTypes.Message | Message}; commands may be mixed case and can include spaces.
    ///
    name: []const u8,
    /// Localization object for the `name` field. Values follow the same restrictions as `name`
    name_localizations: ?LocaleMap, //?Localization,
    /// 1-100 character description
    description: []const u8,
    /// Localization object for the `description` field. Values follow the same restrictions as `description`
    description_localizations: ?LocaleMap, //?Localization,
    ///
    /// If the parameter is required or optional. default `false`
    ///
    /// @remarks
    /// Valid in all option types except {@link ApplicationCommandOptionTypes.SubCommand | SubCommand}; and {@link ApplicationCommandOptionTypes.SubCommandGroup | SubCommandGroup};
    ///
    required: ?bool,
    ///
    /// Choices for the option from which the user can choose, max 25
    ///
    /// @remarks
    /// Only valid in options of type {@link ApplicationCommandOptionTypes.[]const u8 | []const u8};, {@link ApplicationCommandOptionTypes.Integer | Integer};, or {@link ApplicationCommandOptionTypes.isize | isize};
    ///
    /// If you provide an array of choices, they will be the ONLY accepted values for this option
    ///
    choices: ?[]ApplicationCommandOptionChoice,
    ///
    /// If the option is a subcommand or subcommand group type, these nested options will be the parameters
    ///
    /// @remarks
    /// Only valid in option of type {@link ApplicationCommandOptionTypes.SubCommand | SubCommand}; or {@link ApplicationCommandOptionTypes.SubCommandGroup | SubCommandGroup};
    ///
    options: ?[]ApplicationCommandOption,
    ///
    /// If autocomplete interactions are enabled for this option.
    ///
    /// @remarks
    /// Only valid in options of type {@link ApplicationCommandOptionTypes.[]const u8 | []const u8};, {@link ApplicationCommandOptionTypes.Integer | Integer};, or {@link ApplicationCommandOptionTypes.isize | isize};
    ///
    ///When {@link ApplicationCommandOption.choices | choices}; are provided, this may not be set to true
    ///
    autocomplete: ?bool,
    ///
    /// The channels shown will be restricted to these types
    ///
    /// @remarks
    /// Only valid in option of type {@link ApplicationCommandOptionTypes.Channel | Channel};
    ///
    channel_types: ?[]ChannelTypes,
    ///
    /// The minimum permitted value
    ///
    /// @remarks
    /// Only valid in options of type {@link ApplicationCommandOptionTypes.Integer | Integer}; or {@link ApplicationCommandOptionTypes.isize | isize};
    ///
    min_value: ?isize,
    ///
    /// The maximum permitted value
    ///
    /// @remarks
    /// Only valid in options of type {@link ApplicationCommandOptionTypes.Integer | Integer}; or {@link ApplicationCommandOptionTypes.isize | isize};
    ///
    max_value: ?isize,
    ///
    /// The minimum permitted length, should be in the range of from 0 to 600
    ///
    /// @remarks
    /// Only valid in options of type {@link ApplicationCommandOptionTypes.[]const u8 | []const u8};
    ///
    min_length: ?isize,
    ///
    /// The maximum permitted length, should be in the range of from 0 to 600
    ///
    /// @remarks
    /// Only valid in options of type {@link ApplicationCommandOptionTypes.[]const u8 | []const u8};
    ///
    max_length: ?isize,
};

/// https://discord.com/developers/docs/interactions/application-commands#application-command-permissions-object
pub const ApplicationCommandOptionChoice = struct {
    /// 1-100 character choice name
    name: []const u8,
    /// Localization object for the `name` field. Values follow the same restrictions as `name`
    name_localizations: []const u8, //?Localization,
    /// Value for the choice, up to 100 characters if []const u8
    value: union(enum) {
        string: []const u8,
        integer: isize,
    },
};

/// https://discord.com/developers/docs/interactions/slash-commands#guildapplicationcommandpermissions
pub const GuildApplicationCommandPermissions = struct {
    /// ID of the command or the application ID. When the `id` field is the application ID instead of a command ID, the permissions apply to all commands that do not contain explicit overwrites.
    id: Snowflake,
    /// ID of the application the command belongs to
    application_id: Snowflake,
    /// ID of the guild
    guild_id: Snowflake,
    /// Permissions for the command in the guild, max of 100
    permissions: []ApplicationCommandPermissions,
};

/// https://discord.com/developers/docs/interactions/slash-commands#applicationcommandpermissions
pub const ApplicationCommandPermissions = struct {
    /// ID of the role, user, or channel. It can also be a permission constant
    id: Snowflake,
    /// ApplicationCommandPermissionTypes.Role, ApplicationCommandPermissionTypes.User, or ApplicationCommandPermissionTypes.Channel
    type: ApplicationCommandPermissionTypes,
    /// `true` to allow, `false`, to disallow
    permission: bool,
};
