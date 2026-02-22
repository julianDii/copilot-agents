// Fixture: list rendered with array index as key on a filtered list
// Expected finding: Minor — index keys cause incorrect reconciliation on reorder/filter

interface Task {
  id: number
  title: string
  done: boolean
}

export function TaskList({ tasks }: { tasks: Task[] }) {
  return (
    <ul>
      {tasks
        .filter(t => !t.done)
        .map((task, index) => (
          // index key — breaks when tasks are filtered, reordered, or prepended
          <li key={index}>{task.title}</li>
        ))}
    </ul>
  )
}

