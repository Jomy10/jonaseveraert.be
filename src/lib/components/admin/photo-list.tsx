import { createSignal, onMount, onCleanup, For, Show } from "solid-js";
import { type ImageSchema } from "@db/schema";

/// Event dispatched by the upload form when the set of
/// images in the database changed, so this list refreshes itself
export const imagesChangedEvent = "admin:images-changed";

export function PhotoList() {
    const [images, setImages] = createSignal<ImageSchema[]>([]);
    const [pageSize, _setPageSize] = createSignal(25);
    const [loading, setLoading] = createSignal(true);
    const [total, setTotal] = createSignal(0);
    const [page, setPage] = createSignal(0);
    const [error, setError] = createSignal("");

    const pageCount = () => {
        const c = Math.ceil(total() / pageSize());
        if (!Number.isSafeInteger(c) || c <= 0)
            return 1;
        else
            return c;
    };
    const pageIndices = () => {
        if (pageCount() > 0)
            return [...Array(pageCount()).keys()];
        else
            return [0];
    };

    async function fetchImages(pageIndex: number = page()) {
        setLoading(true);
        setError("");

        try {
            const res = await fetch("/admin/api/query-image", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    page_size: pageSize(),
                    page: pageIndex,
                    with_count: true
                })
            });
            if (!res.ok)
                throw new Error(res.statusText || `Request failed with status ${res.status}`);

            const data = await res.json();

            // No more images on this page (last image was deleted)
            if (data.images.length === 0 && pageIndex > 0)
                return goToPage(pageIndex - 1);

            setImages(data.images);
            setTotal(data.count);
        } catch (e: any) {
            setError(e.message ?? "Could not load images");
        } finally {
            setLoading(false);
        }
    }

    async function goToPage(pageIndex: number) {
        setPage(pageIndex);
        await fetchImages(pageIndex);
    }

    async function deleteImage(image: ImageSchema) {
        if (!window.confirm(`Delete "${image.OriginalFileName}"?`))
            return;

        setError("");
        const res = await fetch(`/admin/api/delete-image/${image.Id}`, {
            method: "DELETE",
        });

        if (!res.ok) {
            setError(res.statusText || `Failed to delete image (status ${res.status})`);
            return;
        }

        await fetchImages();
    }

    async function setPageSize(ps: number) {
        if (Number.isSafeInteger(ps) && ps > 0) {
            _setPageSize(ps);
            fetchImages(page());
        }
    }

    const onImagesChanged = () => goToPage(0);

    onMount(() => {
        fetchImages(0);
        window.addEventListener(imagesChangedEvent, onImagesChanged);

        onCleanup(() => window.removeEventListener(imagesChangedEvent, onImagesChanged));
    });

    return (
        <div class="photo-list">
            <style>{css}</style>

            <Show when={error().length > 0}>
                <p class="photo-list-error">{error()}</p>
            </Show>

            <Show when={!loading()} fallback={<p class="photo-list-info">Loading images...</p>}>
                <Show when={images().length > 0} fallback={<p class="photo-list-info">No images found.</p>}>
                    <div class="photo-grid">
                        <For each={images()}>
                            {(image) => (
                                <figure class="photo-card">
                                    <img
                                        src={`/image/gallery/by-id/${image.Id}.webp`}
                                        alt={image.OriginalFileName}
                                        loading="lazy"
                                    />
                                    <figcaption>
                                        <span class="photo-name" title={image.OriginalFileName}>{image.OriginalFileName}</span>
                                        <span class="photo-date">{image.CreatedDate}</span>
                                        <button class="photo-delete" onClick={() => deleteImage(image)}>Delete</button>
                                    </figcaption>
                                </figure>
                            )}
                        </For>
                    </div>

                    <Show when={pageCount() > 1}>
                        <div class="photo-pagination">
                            <button disabled={page() == 0} onClick={() => goToPage(page() - 1)}>
                                ‹ Previous
                            </button>
                            <For each={pageIndices()}>
                                {(pageIndex) => (
                                    <button
                                        classList={{ active: pageIndex == page() }}
                                        onClick={() => goToPage(pageIndex)}
                                    >
                                        {pageIndex + 1}
                                    </button>
                                )}
                            </For>
                            <button disabled={page() >= pageCount() - 1} onClick={() => goToPage(page() + 1)}>
                                Next ›
                            </button>
                        </div>
                    </Show>
                    <div class="photo-page-size">
                        <p>page size: </p>
                        {/* @ts-expect-error Kor doesn't declare Solid JSX types */}
                        <kor-input
                            type="number"
                            style="max-width: 150px"
                            value={pageSize()}
                            onChange={(e: any) => setPageSize(Number(e.target.value))}
                        />
                    </div>
                </Show>
            </Show>
        </div>
    )
};

const css = `
  .photo-list-info {
    color: var(--text-2);
  }

  .photo-list-error {
    color: rgb(var(--functional-red));
  }

  .photo-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: var(--spacing-l);
  }

  .photo-card {
    margin: 0;
    background: rgb(var(--base-3));
    border-radius: var(--border-radius);
    box-shadow: var(--shadow-1);
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }

  .photo-card img {
    width: 100%;
    aspect-ratio: 1;
    object-fit: cover;
    display: block;
    background: rgba(var(--neutral-1), .05);
  }

  .photo-card figcaption {
    padding: var(--spacing-s) var(--spacing-m);
    display: flex;
    flex-direction: column;
    gap: var(--spacing-xs);
    font: var(--body-2);
  }

  .photo-name {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: var(--text-1);
  }

  .photo-date {
    color: var(--text-2);
  }

  .photo-delete {
    align-self: flex-start;
    margin-top: var(--spacing-xs);
    border: none;
    border-radius: var(--border-radius);
    padding: var(--spacing-xs) var(--spacing-m);
    background: rgb(var(--functional-red));
    color: rgb(var(--base-0));
    cursor: pointer;
    font: var(--body-2);
  }

  .photo-delete:hover {
    filter: brightness(1.1);
  }

  .photo-pagination {
    display: flex;
    gap: var(--spacing-s);
    justify-content: center;
    margin-top: var(--spacing-l);
    flex-wrap: wrap;
  }

  .photo-page-size {
    display: flex;
    justify-content: center;
    width: 100%;
    margin-top: var(--spacing-l);
    gap: 0.5rem;
  }

  .photo-pagination button {
    border: none;
    border-radius: var(--border-radius);
    padding: var(--spacing-xs) var(--spacing-m);
    background: rgb(var(--base-3));
    color: var(--text-1);
    cursor: pointer;
    font: var(--body-1);
  }

  .photo-pagination button:hover:not(:disabled) {
    background: rgb(var(--base-4));
  }

  .photo-pagination button.active {
    background: rgb(var(--accent-1));
    color: rgb(var(--base-0));
  }

  .photo-pagination button:disabled {
    opacity: .4;
    cursor: default;
  }
`;
