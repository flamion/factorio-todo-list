
function todo.create_minimized_button(player)
    todo.log("Creating Basic UI for player " .. player.name)

    if (not todo.get_maximize_button(player)
      and not todo.get_main_frame(player)
      and todo.show_minimized(player) ) then
        mod_gui.get_button_flow(player).add({
            type = "button",
            style = "todo_button_default",
            name = "todo_maximize_button",
            caption = {"todo.todo_list"},
        })
    end
end

function todo.create_maximized_frame(player)
    local frame = mod_gui.get_frame_flow(player).add({
        type = "frame",
        name = "todo_main_frame",
        caption = {"todo.todo_list"},
        direction = "vertical"
    })

    todo.create_task_table(frame, player)

    local flow = frame.add({
        type = "flow",
        name = "todo_main_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_add_button",
        caption = {"todo.add"}
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_toggle_done_button",
        caption = {"todo.show_done"}
    })

    if todo.show_minimized(player) then
        flow.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_minimize_button",
            caption = {"todo.minimize"}
        })
    end
end

function todo.create_task_table(frame, player)

    local scroll = frame.add({
        type = "scroll-pane",
        name = "todo_scroll_pane"
    })

    scroll.vertical_scroll_policy = "auto"
    scroll.horizontal_scroll_policy = "never"
    scroll.style.maximal_height = todo.get_window_height(player)
    scroll.style.minimal_height = scroll.style.maximal_height

    local table = scroll.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_task_table",
        column_count = 6
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_done",
        caption = {"", {"todo.title_done"}, "   "}
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_task",
        caption = {"todo.title_task"}
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_assignee",
        caption = {"todo.title_assignee"}
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_up",
        caption = ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_down",
        caption = ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_edit",
        caption = ""
    })

    return table
end

function todo.create_add_edit_frame(player, task)
    local gui = player.gui.center
    local task = task or nil

    if (gui.todo_add_frame ~= nil) then
        gui.todo_add_frame.destroy()
    end

    local frame = gui.add({
        type = "frame",
        name = "todo_add_frame",
        caption = {"todo.add_title"},
        direction = "vertical"
    })

    local table = frame.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_add_task_table",
        column_count = 2
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_add_task_label",
        caption = {"todo.add_task"}
    })

    local textbox = table.add({
        type = "text-box",
        style = "todo_textbox_default",
        name = "todo_new_task_textbox",
        text = task and task.task or ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_add_assignee_label",
        caption = {"todo.add_assignee"}
    })

    local players, lookup, c = todo.get_player_list()
    local assign_index = 1
    if task then
        assign_index = task.assignee and lookup[task.assignee] or 1
    else
        if( todo.is_auto_assign(player) and c == 1 ) then
            assign_index = 2
        end
    end
    table.add({
        type = "drop-down",
        style = "todo_dropdown_default",
        name = "todo_add_assignee_drop_down",
        items = players,
        selected_index = assign_index
    })

    local flow = frame.add({
        type = "flow",
        name = "todo_add_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_cancel_button",
        caption = {"todo.cancel"}
    })

    if task then
        flow.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_update_button_" .. task.id,
            caption = {"todo.update"}
        })
    else
        flow.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_persist_button",
            caption = {"todo.persist"}
        })
    end
end

function todo.add_task_to_table(table, task, completed, is_first, is_last)
    local prefix = ""
    if (completed) then
        prefix = "done_"
    end

    local id = task.id

    table.add({
        type = "checkbox",
        name = "todo_item_checkbox_" .. prefix .. id,
        state = completed
    })

    table.add({
        type = "label",
        style = "todo_label_task",
        name = "todo_item_task_" .. id,
        caption = task.task
    })

    if (task.assignee) then
        table.add({
            type = "label",
            style = "todo_label_default",
            name = "todo_item_assignee_" .. id,
            caption = task.assignee
        })
    else
        table.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_item_assign_self_" .. id,
            caption = {"todo.assign_self"}
        })
    end

    if (is_first) then
        table.add({
            type = "label",
            name = "todo_item_firstup_" .. id,
            caption = ""
        })
    else
        table.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_item_up_" .. id,
            caption = "↑"
        })
    end

    if (is_last) then
        table.add({
            type = "label",
            name = "todo_item_lastdown_" .. id,
            caption = ""
        })
    else
        table.add({
            type = "button",
            style = "todo_button_default",
            name = "todo_item_down_" .. id,
            caption = "↓"
        })
    end

    table.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_item_edit_" .. id,
        caption = {"todo.title_edit"}
    })
end
