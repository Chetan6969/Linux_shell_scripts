#!/bin/bash

TODO_FILE="$HOME/todo.txt"

echo "📌 Simple To-Do List"
echo "1. Add Task"
echo "2. View Tasks"
echo "3. Exit"
read -p "Choose an option: " option

case $option in
    1)
        read -p "Enter a task: " task
        echo "- $task" >> "$TODO_FILE"
        echo "✅ Task added!"
        ;;
    2)
        echo "📜 Your To-Do List:"
        cat "$TODO_FILE"
        ;;
    3)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid option!"
        ;;
esac

