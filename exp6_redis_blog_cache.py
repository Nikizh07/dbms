# ============================================================
# Experiment 6: Develop an In-Memory Caching Solution Using
# Redis for a Content Publishing Platform (Blog)
# ============================================================
# Install dependency:  pip install redis

import json
import redis


class BlogContentCache:
    """Cache layer for blog posts using Redis."""

    def __init__(self, redis_host='localhost', redis_port=6379, redis_db=0):
        self.redis_client = redis.StrictRedis(
            host=redis_host, port=redis_port, db=redis_db
        )

    # ----------------------------------------------------------
    # GET  –  check cache first; fall back to "database" fetch
    # ----------------------------------------------------------
    def get_post(self, post_id, ttl_seconds=300):
        """
        Returns a blog post dict.
        Tries Redis cache first; on miss, simulates a DB fetch
        and stores the result in Redis with a TTL.
        """
        cache_key = f'post:{post_id}'
        cached_post = self.redis_client.get(cache_key)

        if cached_post:
            print(f"[CACHE HIT]  Retrieving post {post_id} from cache.")
            return json.loads(cached_post.decode('utf-8'))
        else:
            # Simulate fetching from a database
            post = {
                'post_id': post_id,
                'title'  : f'Title of Post {post_id}',
                'content': f'Content of Post {post_id}'
            }
            # Cache with expiry (TTL)
            self.redis_client.setex(cache_key, ttl_seconds, json.dumps(post))
            print(f"[CACHE MISS] Fetched post {post_id} from DB and cached.")
            return post

    # ----------------------------------------------------------
    # UPDATE  –  write to "database" and invalidate cache
    # ----------------------------------------------------------
    def update_post(self, post_id, new_title, new_content):
        """Simulate updating a post and invalidating its cache entry."""
        updated_post = {
            'post_id': post_id,
            'title'  : new_title,
            'content': new_content
        }
        # In a real app: db.execute("UPDATE posts SET ... WHERE id = %s", post_id)
        print(f"[DB UPDATE]  Post {post_id} updated in database.")

        # Invalidate cache
        self.redis_client.delete(f'post:{post_id}')
        print(f"[CACHE DEL]  Cache entry for post {post_id} invalidated.")
        return updated_post

    # ----------------------------------------------------------
    # DELETE  –  remove from "database" and cache
    # ----------------------------------------------------------
    def delete_post(self, post_id):
        """Simulate deleting a post from DB and removing from cache."""
        # In a real app: db.execute("DELETE FROM posts WHERE id = %s", post_id)
        self.redis_client.delete(f'post:{post_id}')
        print(f"[DELETED]    Post {post_id} removed from DB and cache.")

    # ----------------------------------------------------------
    # CACHE STATS
    # ----------------------------------------------------------
    def cache_info(self):
        """Display Redis server info (useful for monitoring)."""
        info = self.redis_client.info(section='stats')
        hits   = info.get('keyspace_hits', 0)
        misses = info.get('keyspace_misses', 0)
        total  = hits + misses
        rate   = (hits / total * 100) if total else 0
        print(f"\n--- Cache Stats ---")
        print(f"Hits  : {hits}")
        print(f"Misses: {misses}")
        print(f"Hit Rate: {rate:.1f}%")


# -------------------------
# Example Usage
# -------------------------
if __name__ == "__main__":
    blog_cache = BlogContentCache()

    # First access – cache miss, fetches from "DB"
    post1 = blog_cache.get_post(1)
    print(f"Post: {post1}\n")

    # Second access – cache hit
    cached_post1 = blog_cache.get_post(1)
    print(f"Cached Post: {cached_post1}\n")

    # Fetch a different post
    post2 = blog_cache.get_post(2)
    print(f"Post: {post2}\n")

    # Update invalidates cache
    blog_cache.update_post(1, "Updated Title", "Updated Content")

    # Next fetch will be a cache miss again
    refreshed = blog_cache.get_post(1)
    print(f"Refreshed Post: {refreshed}\n")

    # Delete a post
    blog_cache.delete_post(2)

    # Cache stats
    blog_cache.cache_info()
