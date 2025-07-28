// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Decentralized To-Do List
 * @dev A smart contract for managing personal tasks on the blockchain
 * @author Your Name
 */
contract DecentralizedTodoList {
    
    // Task structure
    struct Task {
        uint256 id;
        string content;
        bool completed;
        uint256 createdAt;
        uint256 completedAt;
        address owner;
    }
    
    // State variables
    mapping(address => Task[]) private userTasks;
    mapping(address => uint256) private taskCounters;
    
    // Events
    event TaskCreated(address indexed user, uint256 indexed taskId, string content);
    event TaskCompleted(address indexed user, uint256 indexed taskId);
    event TaskDeleted(address indexed user, uint256 indexed taskId);
    
    // Modifiers
    modifier onlyTaskOwner(uint256 _taskId) {
        require(_taskId < userTasks[msg.sender].length, "Task does not exist");
        require(userTasks[msg.sender][_taskId].owner == msg.sender, "Not task owner");
        _;
    }
    
    /**
     * @dev Core Function 1: Create a new task
     * @param _content The content/description of the task
     */
    function createTask(string memory _content) external {
        require(bytes(_content).length > 0, "Task content cannot be empty");
        require(bytes(_content).length <= 500, "Task content too long");
        
        uint256 newTaskId = taskCounters[msg.sender];
        
        Task memory newTask = Task({
            id: newTaskId,
            content: _content,
            completed: false,
            createdAt: block.timestamp,
            completedAt: 0,
            owner: msg.sender
        });
        
        userTasks[msg.sender].push(newTask);
        taskCounters[msg.sender]++;
        
        emit TaskCreated(msg.sender, newTaskId, _content);
    }
    
    /**
     * @dev Core Function 2: Mark a task as completed
     * @param _taskId The ID of the task to complete
     */
    function completeTask(uint256 _taskId) external onlyTaskOwner(_taskId) {
        require(!userTasks[msg.sender][_taskId].completed, "Task already completed");
        
        userTasks[msg.sender][_taskId].completed = true;
        userTasks[msg.sender][_taskId].completedAt = block.timestamp;
        
        emit TaskCompleted(msg.sender, _taskId);
    }
    
    /**
     * @dev Core Function 3: Delete a task
     * @param _taskId The ID of the task to delete
     */
    function deleteTask(uint256 _taskId) external onlyTaskOwner(_taskId) {
        uint256 lastIndex = userTasks[msg.sender].length - 1;
        
        // Move the last task to the position of the task to delete
        if (_taskId != lastIndex) {
            userTasks[msg.sender][_taskId] = userTasks[msg.sender][lastIndex];
        }
        
        // Remove the last task
        userTasks[msg.sender].pop();
        
        emit TaskDeleted(msg.sender, _taskId);
    }
    
    /**
     * @dev Get all tasks for the caller
     * @return Array of all user's tasks
     */
    function getMyTasks() external view returns (Task[] memory) {
        return userTasks[msg.sender];
    }
    
    /**
     * @dev Get a specific task by ID
     * @param _taskId The ID of the task to retrieve
     * @return The requested task
     */
    function getTask(uint256 _taskId) external view onlyTaskOwner(_taskId) returns (Task memory) {
        return userTasks[msg.sender][_taskId];
    }
    
    /**
     * @dev Get the total number of tasks for the caller
     * @return Total number of tasks created by the user
     */
    function getTaskCount() external view returns (uint256) {
        return userTasks[msg.sender].length;
    }
    
    /**
     * @dev Get completed tasks count for the caller
     * @return Number of completed tasks
     */
    function getCompletedTasksCount() external view returns (uint256) {
        uint256 completedCount = 0;
        Task[] memory tasks = userTasks[msg.sender];
        
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].completed) {
                completedCount++;
            }
        }
        
        return completedCount;
    }
    
    /**
     * @dev Get pending tasks count for the caller
     * @return Number of pending tasks
     */
    function getPendingTasksCount() external view returns (uint256) {
        uint256 pendingCount = 0;
        Task[] memory tasks = userTasks[msg.sender];
        
        for (uint256 i = 0; i < tasks.length; i++) {
            if (!tasks[i].completed) {
                pendingCount++;
            }
        }
        
        return pendingCount;
    }
}
