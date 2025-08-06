import 'package:eishen_matrix/models/custom_alert_dialog.dart';
import 'package:eishen_matrix/models/custom_list_tile.dart';
import 'package:eishen_matrix/services/task_service.dart';
import 'package:eishen_matrix/task.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskNameController = TextEditingController();

  // Add selected date state
  DateTime _selectedDate = DateTime.now();

  // Separate scroll controllers for each quadrant to enable auto-scrolling
  // when new tasks are added to specific quadrants
  final ScrollController _quadrant1ScrollController = ScrollController();
  final ScrollController _quadrant2ScrollController = ScrollController();
  final ScrollController _quadrant3ScrollController = ScrollController();
  final ScrollController _quadrant4ScrollController = ScrollController();

  // Shows a dialog to add a new task to the specified quadrant
  // [quadrant] - The quadrant where the task will be added
  void onPlusButton(Quadrant quadrant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          controller: _taskNameController,
          title: 'Add a Task',
          onAdd: (taskName) async {
            //convert the quadrant enum to int for storage
            int quadrantInt;
            switch (quadrant) {
              case Quadrant.one:
                quadrantInt = 0;
                break;
              case Quadrant.two:
                quadrantInt = 1;
                break;
              case Quadrant.three:
                quadrantInt = 2;
                break;
              case Quadrant.four:
                quadrantInt = 3;
                break;
            }
            //create and save the task to database
            final task = Task(name: taskName, quadrant: quadrantInt);
            task.date = _selectedDate; // Set the date for the task
            await _taskService.addTask(task);
            _taskNameController.clear();
            setState(() {});
            // Auto-scroll to show the newly added task
            _scrollToNewTask(quadrant);
          },
        );
      },
    );
  }

  //go to previous day
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  //go to next day
  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  // Get formatted date string
  String get _formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final yesterday = today.subtract(Duration(days: 1));

    if (_isSameDay(_selectedDate, today)) {
      return 'Today';
    } else if (_isSameDay(_selectedDate, tomorrow)) {
      return 'Tomorrow';
    } else if (_isSameDay(_selectedDate, yesterday)) {
      return 'Yesterday';
    } else {
      return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    }
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get tasks for selected date by quadrant
  List<Task> _getTasksForSelectedDate(Quadrant quadrant) {
    return _taskService.getTasksByQuadrantAndDate(quadrant, _selectedDate);
  }

  // Automatically scrolls to the newly added task in the specified quadrant
  // This provides visual feedback to the user that their task was added
  void _scrollToNewTask(Quadrant quadrant) {
    ScrollController? controller;
    switch (quadrant) {
      case Quadrant.one:
        controller = _quadrant1ScrollController;
        break;
      case Quadrant.two:
        controller = _quadrant2ScrollController;
        break;
      case Quadrant.three:
        controller = _quadrant3ScrollController;
        break;
      case Quadrant.four:
        controller = _quadrant4ScrollController;
        break;
    }
    // Schedule the scroll animation to happen after the widget rebuilds
    // This ensures the new task is rendered before we try to scroll to it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the controller is attached to a scrollable widget
      if (controller!.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _updateTask(Task task, String newName, int newQuadrant) async {
    // Update task properties
    task.name = newName;
    task.quadrant = newQuadrant;
    task.updatedAt = DateTime.now();
    _taskNameController.clear();
    // Save to database
    await _taskService.updateTask(task);

    // Refresh UI
    setState(() {});

    // Show confirmation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Task updated successfully')));
  }

  void _showEditDialog(Task task) {
    final TextEditingController editController = TextEditingController(
      text: task.name,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          controller: editController,
          title: 'Edit Task',
          onAdd: (taskName) {}, // Won't be used in edit mode
          isEditing: true, // This makes it edit mode
          currentQuadrant: task.quadrant, // Pass current quadrant
          onUpdate: (newName, newQuadrant) {
            _updateTask(task, newName, newQuadrant); // Call our update method
          },
        );
      },
    );
  }

  final TaskService _taskService = TaskService();
  bool _isLoading = true;

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when page opens
  }

  /// Clean up resources when the widget is disposed
  @override
  void dispose() {
    // Dispose all scroll controllers to prevent memory leaks
    _quadrant1ScrollController.dispose();
    _quadrant2ScrollController.dispose();
    _quadrant3ScrollController.dispose();
    _quadrant4ScrollController.dispose();
    super.dispose();
  }

  /// Helper method to build a single quadrant container
  /// Reduces code duplication since all quadrants have similar structure
  ///
  /// [tasks] - List of tasks for this quadrant
  /// [quadrant] - The quadrant enum value
  /// [color] - Background color for this quadrant
  /// [title] - Display title for this quadrant
  /// [scrollController] - Controller to handle scrolling in this quadrant
  Widget _buildQuadrantContainer({
    required List<Task> tasks,
    required Quadrant quadrant,
    required Color color,
    required String title,
    required ScrollController scrollController,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Quadrant title at the top
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                // Show placeholder text when no tasks exist
                child:
                    tasks.isEmpty
                        ? Center(
                          child: Text(
                            'No task yet',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: ValueKey(
                                tasks[index].name,
                              ), // must be unique!
                              direction:
                                  DismissDirection.endToStart, // swipe left
                              background: Container(
                                color: const Color.fromARGB(255, 230, 100, 91),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (direction) async {
                                // Delete the task from the database
                                final task = tasks[index];
                                await _taskService.deleteTask(task);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${tasks[index].name} deleted',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Listener(
                                onPointerDown: (event) {
                                  if (event.buttons == 2) {
                                    // Right mouse button = 2
                                    _showEditDialog(tasks[index]);
                                  }
                                },

                                child: GestureDetector(
                                  onLongPress:
                                      () => _showEditDialog(tasks[index]),

                                  child: CustomListTile(
                                    task: tasks[index],
                                    onTap: () async {
                                      tasks[index].toggleCompletion();
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: FloatingActionButton.small(
              onPressed: () => onPlusButton(quadrant),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get tasks for selected date
    List<Task> quadrant1Tasks = _getTasksForSelectedDate(Quadrant.one);
    List<Task> quadrant2Tasks = _getTasksForSelectedDate(Quadrant.two);
    List<Task> quadrant3Tasks = _getTasksForSelectedDate(Quadrant.three);
    List<Task> quadrant4Tasks = _getTasksForSelectedDate(Quadrant.four);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eisenhower Matrix'),
        centerTitle: true,
        toolbarHeight: 36, // Reduced from default 56 to 40
        actions: [
          TextButton.icon(
            onPressed: _showDatePicker,
            icon: Icon(Icons.calendar_today, color: Colors.white),
            label: Text(
              _formattedDate,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _goToPreviousDay,
                  icon: Icon(Icons.chevron_left),
                  tooltip: 'Previous Day',
                ),
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formattedDate,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _goToNextDay,
                  icon: Icon(Icons.chevron_right),
                  tooltip: 'Next Day',
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // First row
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuadrantContainer(
                            tasks: quadrant1Tasks,
                            quadrant: Quadrant.one,
                            color: Theme.of(
                              context,
                            ).colorScheme.errorContainer.withOpacity(0.3),
                            title: 'Urgent & Important',
                            scrollController: _quadrant1ScrollController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuadrantContainer(
                            tasks: quadrant2Tasks,
                            quadrant: Quadrant.two,
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.4),
                            title: 'Important, Not Urgent',
                            scrollController: _quadrant2ScrollController,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Second row
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuadrantContainer(
                            tasks: quadrant3Tasks,
                            quadrant: Quadrant.three,
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer.withOpacity(0.4),
                            title: 'Urgent, Not Important',
                            scrollController: _quadrant3ScrollController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuadrantContainer(
                            tasks: quadrant4Tasks,
                            quadrant: Quadrant.four,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.5),
                            title: 'Neither Urgent nor Important',
                            scrollController: _quadrant4ScrollController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
