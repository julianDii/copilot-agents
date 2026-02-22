// Fixture: XSS via dangerouslySetInnerHTML with unsanitized user input
// Expected finding: Blocker — user-controlled HTML rendered without sanitization

interface Comment {
  author: string
  body: string // user-supplied HTML content from API
}

export function CommentList({ comments }: { comments: Comment[] }) {
  return (
    <ul>
      {comments.map((comment, i) => (
        <li key={i}>
          <strong>{comment.author}</strong>
          {/* XSS: body comes from user input, rendered as raw HTML */}
          <div dangerouslySetInnerHTML={{ __html: comment.body }} />
        </li>
      ))}
    </ul>
  )
}

