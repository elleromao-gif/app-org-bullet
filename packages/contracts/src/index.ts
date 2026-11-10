export type UUID = string;

export type EntryKind = 'note' | 'task' | 'event' | 'idea';

export interface CreateEntryInput {
  clientOperationId: UUID;
  kind: EntryKind;
  title?: string;
  content: string;
  occurredAt?: string;
  tagIds?: UUID[];
}

export interface EntryRecord {
  id: UUID;
  userId: UUID;
  kind: EntryKind;
  title: string | null;
  content: string;
  version: number;
  createdAt: string;
  updatedAt: string;
}

export interface AIInterpretationProposal {
  sourceText: string;
  proposedTitle?: string;
  proposedKind: EntryKind;
  dueAt?: string;
  priority?: 'low' | 'medium' | 'high';
  categorySuggestions: string[];
  duplicateCandidateIds: UUID[];
  requiresReview: boolean;
}
