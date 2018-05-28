quoted = MIME.Application.quoted(Application.get_env(:mime, :types, %{}))
Module.create(MIME, quoted, __ENV__)
