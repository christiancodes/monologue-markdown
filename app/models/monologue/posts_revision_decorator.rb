Monologue::PostsRevision.class_eval do
  before_validation do
    if self.post.nil? || self.post.posts_revision_id.nil?
      self.is_markdown = true
    else
      self.is_markdown = self.post.active_revision.is_markdown
    end
  end

  def is_markdown?
    self.is_markdown != false
  end

  def content
    if self.is_markdown? && !in_admin?(caller)
      pipeline = Content::Pipeline.new([Content::Pipeline::Filters::Markdown, Content::Pipeline::Filters::CodeHighlight], markdown: { type: :gfm, safe: true })
      return pipeline.filter(read_attribute(:content))
    end
    read_attribute(:content)
  end

  def in_admin? caller
    caller.each do |c|
      return true if c.include? "app/controllers/monologue/admin/posts_controller.rb"
    end
    return false
  end
end